require 'elastic_search_corpus'

class CorpusRepository
  TYPE_PATTERNS = {
    'ruby' => '**/*.rb',
    'java' => '**/*.java'
  }

  def initialize
    @corpuses = {}
  end

  def corpus_for_type(type)
    pattern = TYPE_PATTERNS.fetch(type)
    @corpuses[type] ||= ElasticSearchCorpus.new(type, pattern)
  end
end
