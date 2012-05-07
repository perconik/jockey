require 'elastic_search_corpus'

class CorpusRepository
  def initialize
    @corpuses = {}
  end

  def corpus_for_type(type)
    @corpuses[type] ||= ElasticSearchCorpus.new(type)
  end
end
