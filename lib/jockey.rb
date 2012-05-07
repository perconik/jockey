require 'naive_source_code_tokenizer'
require 'elastic_search_corpus'
require 'elastic_search_index'
require 'corpus_repository'
require 'code_finder'
require 'bayesian_classifier'

class TokenPreprocessor
  def self.transform(token)
    token.downcase
  end
end

class FrequencySampler
  def self.sample(path, frequencies, tokenizer, preprocessor = TokenPreprocessor)
    tokenizer.tokenize(path).each do |token|
      token = preprocessor.transform(token)
      frequencies[token] ||= 0
      frequencies[token] += 1
    end
  end
end

class TfIdf
  def self.calculate(in_doc_freq, tokens_in_doc, corpus_appearance, docs_in_corpus)
    tf = in_doc_freq.to_f / tokens_in_doc.to_f
    idf =  Math.log(docs_in_corpus.to_f / corpus_appearance.to_f)
    tf * idf
  end
end

class StdOutReporter
  def self.report(tfidfs)
    tfidfs.each_pair do |token, tfidf|
      puts("%s: %.3f" % [token, tfidf])
    end
  end
end

class SortByTfIdf
  def self.run(tfidfs)
    tfidfs.sort_by { |k,v| v }.reverse.inject(Hash.new) { |memo, pair| memo[pair[0]] = pair[1]; memo }
  end
end

class Jockey
  def self.tf_idf(path_to_file, classifier = BayesianClassifier.new, reporter = StdOutReporter, filters = [SortByTfIdf])
    type = classifier.classify(File.read(path_to_file)).downcase
    puts "Document classified as #{type}"
    corpus = corpus_repository.corpus_for_type(type)
    frequencies = {}
    tfidfs = {}
    sampler.sample(path_to_file, frequencies, NaiveSourceCodeTokenizer)
    corpus_frequencies = corpus.frequencies(frequencies.keys)
    frequencies.each_pair do |token, frequency|
      puts "Token: #{token}, frequency in corpus: #{corpus_frequencies[token]}, corpus size: #{corpus.size}"
      tfidf = TfIdf.calculate(frequency, frequencies.size, corpus_frequencies[token], corpus.size)
      tfidfs[token] = tfidf
    end

    reporter.report(run_filters(tfidfs, filters))
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

  def self.run_filters(tfidfs, filters)
    filters.inject(tfidfs) { |memo, filter| filter.run(memo) }
  end

  def self.corpus_repository
    @repository ||= CorpusRepository.new
  end

  def self.sampler
    @sampler ||= FrequencySampler
  end

  def classifier
    @classifier = CodeClassifier.new
  end
end
