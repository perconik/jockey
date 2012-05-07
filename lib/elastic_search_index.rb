require 'json'
require 'hashugar'
require 'curb'
require 'settings'

class ElasticSearchIndex
  def initialize(type, config = Settings)
    @type = type
    @base_url = "http://#{config.elastic.host}:#{config.elastic.port}/#{config.elastic.index}"
    create_mapping_for(type) unless mapping_exists?(type)
  end

  def create
    settings = <<-JSON
      {
        "settings":{
          "analysis": {
            "analyzer": {
              "source_code":{
                "type": "custom",
                "tokenizer": "pattern",
                "filter": ["lowercase", "asciifolding"]
              }
            }
          }
        }
      }
    JSON
    response = Curl::Easy.http_put(@base_url, settings)
    raise Exception.new(response.body_str) if response.response_code == 500 || response.response_code == 400
  end

  def drop
    response = Curl::Easy.http_delete(@base_url)
    raise Exception.new(response.body_str) if response.response_code == 500 || response.response_code == 400
  end

  def recreate
    drop
    create
  end

  def create_mapping_for(type)
    mapping = <<-JSON
      {
        "#{type}": {
          "properties": {
            "code": {
              "type": "string",
              "store": "no",
              "analyzer": "source_code"
            }
          },
          "_all": {
            "analyzer": "source_code"
          }
        }
      }
    JSON
    response = Curl::Easy.http_put(document_mapping_url, mapping)
    raise Exception.new(response.body_str) if response.response_code == 500 || response.response_code == 400
  end

  def mapping_exists?(type)
    response = Curl::Easy.http_get(document_mapping_url)
    raise Exception.new(response.body_str) if response.response_code == 500 || response.response_code == 400
    response.response_code == 200
  end

  def index(document)
    response = Curl::Easy.http_post(document_url, document_to_json(document))
    raise Exception.new(response.body_str) if response.response_code == 500 || response.response_code == 400
  end

  def count
    response = Curl::Easy.http_get(count_url)
    raise Exception.new(response.body_str) if response.response_code == 500 || response.response_code == 400
    JSON.parse(response.body_str).to_hashugar
  end

  def bulk_search(tokens, options)
    search_type = options[:search_type]
    query = ""
    tokens.each do |token|
      query << <<-QUERY
        {"search_type": "#{search_type}"}
        {"filter" : { "term": { "code": "#{token}" }}}
      QUERY
    end
    response = Curl::Easy.http_post(document_msearch_url, query)
    raise Exception.new(response.body_str) if response.response_code == 500 || response.response_code == 400
    JSON.parse(response.body_str).to_hashugar
  end

  private

  def document_url
    "#{@base_url}/#{@type}/"
  end

  def count_url
    "#{@base_url}/#{@type}/_count"
  end

  def document_mapping_url
    "#{@base_url}/#{@type}/_mapping"
  end

  def document_msearch_url
    "#{@base_url}/#{@type}/_msearch"
  end

  def search_params(token)
    <<-JSON
    {
      "filter": {
        "term": { "code": "#{escape_javascript(token)}" }
      }
    }
    JSON
  end

  def document_to_json(document)
    <<-JSON
    {
      "#{@type}": {
        "code": "#{escape_javascript(document)}"
      }
    }
    JSON
  end

  JS_ESCAPE_MAP = {
    '\\'    => '\\\\',
    '</'    => '<\/',
    "\r\n"  => '\n',
    "\n"    => '\n',
    "\r"    => '\n',
    '"'     => '\\"',
    "/"     => '\/',
    "\t"    => '\t'
  }

  def escape_javascript(javascript)
    javascript.gsub(/(\\|<\/|\r\n|\342\200\250|[\n\r\t"]|\/)/u) {|match| JS_ESCAPE_MAP[match] }
  end
end
