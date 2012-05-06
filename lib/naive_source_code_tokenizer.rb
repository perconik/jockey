class NaiveSourceCodeTokenizer
  def self.tokenize(path, &block)
    text = File.read(path)
    text.scan(/[a-zA-Z_]{1}[_a-zA-Z0-9]*/, &block)
  end
end
