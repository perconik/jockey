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
    @jockey.tf_idf(document).to_json
  end

  run! if app_file == $0

end
