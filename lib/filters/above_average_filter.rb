class AboveAverageFilter
  def filter(tfidfs)
    sum = tfidfs.inject(0) { |sum, hash| kw, score = hash; sum += score; sum }
    average = sum / tfidfs.size
    tfidfs.inject(Hash.new) { |hash, kv| k, v = kv; hash[k] = v if v > average; hash }
  end
end
