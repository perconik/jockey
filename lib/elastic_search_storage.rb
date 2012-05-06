require 'elastic_search_index'

class ElasticSearchStorage
  def put(document)
    index.index(document)
  end

  def size
    @index_size ||= index.statistics._all.primaries.docs.count
  end

  def frequencies(tokens)
    frequencies = {}
    result = index.bulk_search(tokens, search_type: :count)
    tokens.each_with_index do |token, index|
      frequencies[token] = result.responses[index].hits.total
    end
    frequencies
  end

  private

  def index
    @index ||= ElasticSearchIndex.new
  end
end
