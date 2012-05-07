require 'elastic_search_index'

class ElasticSearchCorpus
  def initialize(type, pattern, index = nil)
    @index = index || ElasticSearchIndex.new(type)
    @pattern = pattern
  end

  def index(path)
    Dir.glob("#{path}/#{@pattern}").each do |path|
      puts "Indexing #{path}"
      unless File.directory?(path)
        begin
          @index.index(File.read(path))
        rescue Exception => e
          puts e
        end
      end
    end
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
