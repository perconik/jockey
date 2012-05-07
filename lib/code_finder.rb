class CodeFinder
  TYPE_PATTERNS = {
    'ruby' => '**/*.rb',
    'java' => '**/*.java'
  }

  class FileReader
    def initialize(path, pattern)
      @path = path
      @pattern = pattern
    end

    def each_file(&block)
      Dir.glob("#{@path}/#{@pattern}").each do |path|
        unless File.directory?(path)
          block.call(File.read(path))
        end
      end
    end
  end

  def self.lookup_types(path)
    types = Dir.glob("#{path}/*").inject({}) do |type_hash, type_path|
      type = File.basename(type_path)
      type_hash[type] = FileReader.new(type_path, TYPE_PATTERNS.fetch(type)) unless type == "off"
      type_hash
    end
  end
end
