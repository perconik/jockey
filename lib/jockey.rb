require 'naive_source_code_tokenizer'
require 'elastic_search_corpus'
require 'elastic_search_index'
require 'corpus_repository'

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
  def self.tf_idf(type, path_to_file, reporter = StdOutReporter, filters = [SortByTfIdf])
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

  def self.train(corpus_path)
    Dir.glob("#{corpus_path}/*").each do |type_path|
      type = File.basename(type_path)
      corpus = corpus_repository.corpus_for_type(type)
      corpus.index(type_path)
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
end
