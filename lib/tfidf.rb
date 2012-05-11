class TfIdf
  Infinity = 1.0/0.0

  def self.calculate(in_doc_freq, tokens_in_doc, corpus_appearance, docs_in_corpus)
    tf = in_doc_freq.to_f / tokens_in_doc.to_f
    idf =  Math.log(docs_in_corpus.to_f / corpus_appearance.to_f)
    idf = 0 if idf == Infinity
    tf * idf
  end
end

