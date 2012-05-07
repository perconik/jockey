$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'elastic_search_index'

namespace :index do
  desc "Recreate index"
  task :recreate do
    index = ElasticSearchIndex.new("everything")
    index.drop
    index.create
  end
end
