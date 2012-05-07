require 'elastic_search_index'

class ElasticSearchCorpus
  def initialize(type, index = nil)
    @index = index || ElasticSearchIndex.new(type)
  end

  def index(document)
    @index.index(document)
  end

  def size
    @index_size ||= @index.count.count
  end

  def frequencies(tokens)
    frequencies = {}
    result = @index.bulk_search(tokens, search_type: :count)
    tokens.each_with_index do |token, index|
      frequencies[token] = result.responses[index].hits.total
    end
    frequencies
  end

  def recreate!
    @index.recreate
  end
end
