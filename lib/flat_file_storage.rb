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

