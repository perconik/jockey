require 'sinatra/base'
require 'erb'
require 'json'

$LOAD_PATH.unshift(File.dirname(__FILE__), '..', 'lib')
require 'jockey'

class V1Api < Sinatra::Base

  def initialize
    super
    @jockey = Jockey.new
  end

  get '/' do
    erb :instructions
  end

  post '/keywords' do
    document = params[:document]
    content_type 'application/json'
    JSON.pretty_generate(@jockey.tf_idf(document))
  end

  run! if app_file == $0

end
