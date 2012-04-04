class NaiveSourceCodeTokenizer
  def self.tokenize(path, &block)
    text = File.read(path)
    text.scan(/[a-zA-Z]{1}[a-zA-Z0-0]*/, &block)
  end
end

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

class GlobalFrequencySampler
  def self.sample(path, frequencies, tokenizer, preprocessor = TokenPreprocessor)
    tokenizer.tokenize(path).uniq.each do |token|
      token = preprocessor.transform(token)
      frequencies[token] ||= 0
      frequencies[token] += 1
    end
  end
end

class FlatFileStorage
  def initialize(path)
    @path = path
    @metadata_path = "#{@path}.metadata"
  end

  def store_global_frequencies(frequencies)
    File.open(@path, 'w') do |f|
      frequencies.each_pair do |token, frequency|
        f << "#{token}: #{frequency}\n"
      end
    end
  end

  def store_document_count(count)
    File.open(@metadata_path, 'w') do |f|
      f << "#{count}"
    end
  end

  def size
    @size ||= load_size
  end

  def frequency(token)
    contents[token]
  end

  private

  def contents
    @content ||= load_contents
  end

  def load_contents
    File.open(@path).readlines.inject(Hash.new) do |contents, line|
      token, freq = line.split(':')
      contents[token] = freq.to_f
      contents
    end
  end

  def load_size
    File.open(@metadata_path).read
  end
end

class BackgroundCorpus
  def initialize(storage)
    @storage = storage
  end

  def index(directories, sampler = GlobalFrequencySampler, tokenizer = NaiveSourceCodeTokenizer)
    token_frequencies = {}
    docs_in_corpus = 0
    directories.each do |directory|
      Dir.glob("#{directory}/**/*.rb").each do |path|
        puts "Tokenizing #{path}"
        unless File.directory?(path)
          sampler.sample(path, token_frequencies, tokenizer)
          docs_in_corpus += 1
        end
      end
    end
    @storage.store_global_frequencies(token_frequencies)
    @storage.store_document_count(docs_in_corpus)
  end

  def size
    @storage.size
  end

  def frequency(token)
    @storage.frequency(token)
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
  def self.tf_idf(path_to_file, reporter = StdOutReporter, filters = [SortByTfIdf])
    frequencies = {}
    tfidfs = {}
    sampler.sample(path_to_file, frequencies, NaiveSourceCodeTokenizer)
    frequencies.each_pair do |token, frequency|
      tfidf = TfIdf.calculate(frequency, frequencies.size, corpus.frequency(token), corpus.size)
      tfidfs[token] = tfidf
    end

    reporter.report(run_filters(tfidfs, filters))
  end

  def self.index(paths)
    corpus.index(paths)
  end

  private

  def self.run_filters(tfidfs, filters)
    filters.inject(tfidfs) { |memo, filter| filter.run(memo) }
  end

  def self.corpus
    @corpus ||= BackgroundCorpus.new(FlatFileStorage.new('corpus.txt'))
  end

  def self.sampler
    @sampler ||= FrequencySampler
  end
end
