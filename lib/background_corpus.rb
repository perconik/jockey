class BackgroundCorpus
  def initialize(storage)
    @storage = storage
  end

  def index(directories)
    directories.each do |directory|
      Dir.glob("#{directory}/**/*.rb").each do |path|
        puts "Indexing #{path}"
        unless File.directory?(path)
          begin
            @storage.put(File.read(path))
          rescue Exception => e
            puts e
          end
        end
      end
    end
  end

  def size
    @storage.size
  end

  def frequencies(tokens)
    @storage.frequencies(tokens)
  end
end

