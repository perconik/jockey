require 'classifier'
require 'madeleine'

class CodeClassifier
  def train(types)
    m = SnapshotMadeleine.new("bayes_data") do
      bayes = Classifier::Bayes.new(types.keys)
    end
    m.system.train 
  end
end
