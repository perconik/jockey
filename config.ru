$LOAD_PATH.unshift('api')
$LOAD_PATH.unshift('lib')
require 'v1'

map '/jockey/v1/' do
  run V1Api
end
