require 'json'
require 'hashugar'
require 'curb'
require 'settings'

class ElasticSearchIndex
  def initialize(config = Settings)
    @base_url = "http://#{config.elastic.host}:#{config.elastic.port}/#{config.elastic.index}"
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
        },
        "mappings":{
          "document": {
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
      }
    JSON
    response = Curl::Easy.http_put(@base_url, settings)
    raise Exception.new(response.body_str) if response.response_code == 500 || response.response_code == 400
  end

  def drop
    response = Curl::Easy.http_delete(@base_url)
    raise Exception.new(response.body_str) if response.response_code == 500 || response.response_code == 400
  end

  def index(document)
    response = Curl::Easy.http_post(document_url, document_to_json(document))
    raise Exception.new(response.body_str) if response.response_code == 500 || response.response_code == 400
  end

  def statistics
    response = Curl::Easy.http_get(stats_url)
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
    "#{@base_url}/document/"
  end

  def stats_url
    "#{@base_url}/_stats"
  end

  def document_msearch_url
    "#{@base_url}/document/_msearch"
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
      "document": {
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
