class NaiveSourceCodeTokenizer
  def self.tokenize(text, &block)
    text.scan(/[a-zA-Z_]{1}[_a-zA-Z0-9]*/, &block)
  end
end
