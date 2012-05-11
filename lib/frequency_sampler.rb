class FrequencySampler
  class TokenPreprocessor
    def self.transform(token)
      token.downcase
    end
  end

  def self.sample(document, frequencies, tokenizer, preprocessor = TokenPreprocessor)
    tokenizer.tokenize(document).each do |token|
      token = preprocessor.transform(token)
      frequencies[token] ||= 0
      frequencies[token] += 1
    end
  end
end
