require 'classifier'
require 'madeleine'
require 'yaml'

class BayesianClassifier
  def initialize(types = nil)
    @m = SnapshotMadeleine.new("bayes_data", YAML) do
      Classifier::Bayes.new(*types)
    end
  end

  def training(&block)
    yield self
    commit
  end

  def train(type, document)
    @m.system.train(type, document)
  end

  def commit
    @m.take_snapshot
  end

  def classify(document)
    @m.system.classify(document)
  end
end
