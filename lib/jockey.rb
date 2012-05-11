require 'naive_source_code_tokenizer'
require 'elastic_search_corpus'
require 'corpus_repository'
require 'code_finder'
require 'bayesian_classifier'
require 'frequency_sampler'
require 'tfidf'

class Jockey
  def self.tf_idf(document, classifier = BayesianClassifier.new)
    type = classifier.classify(document).downcase
    puts "Document classified as #{type}"
    corpus = corpus_repository.corpus_for_type(type)
    frequencies = {}
    tfidfs = {}
    sampler.sample(document, frequencies, NaiveSourceCodeTokenizer)
    corpus_frequencies = corpus.frequencies(frequencies.keys)
    frequencies.each_pair do |token, frequency|
      puts "Token: #{token}, frequency in corpus: #{corpus_frequencies[token]}, corpus size: #{corpus.size}"
      tfidf = TfIdf.calculate(frequency, frequencies.size, corpus_frequencies[token], corpus.size)
      tfidfs[token] = tfidf
    end

    tfidfs
  end

  def self.train(corpus_path, classifier_class = BayesianClassifier)
    types = CodeFinder.lookup_types(corpus_path)
    classifier_class.new(types.keys).training do |classifier|
      types.each do |type, reader|
        puts "\nTraining type #{type}"
        corpus = corpus_repository.corpus_for_type(type)
        reader.each_file do |document|
          print '.'
          begin
            corpus.index(document)
            classifier.train(type, document)
          rescue Exception => e
            puts e
          end
        end
      end
    end
  end

  private

  def self.corpus_repository
    @repository ||= CorpusRepository.new
  end

  def self.sampler
    @sampler ||= FrequencySampler
  end
end
