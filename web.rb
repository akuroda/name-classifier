require 'sinatra'
require "sinatra/reloader" if development?
require 'json'
require './classifier'

configure :production do
  require 'newrelic_rpm'
end

configure do
  set :classifier, NameClassifier.new("athletes.csv")
end

get '/' do
  erb :index
end

get '/help' do
  erb :help
end

get '/json' do
  firstname = params[:name].split(/,/)[1].strip.downcase
  fullname = params[:name].gsub(/,/, '').strip.downcase
  if firstname.empty? or fullname.empty?
    status 400
  end

  data = { country: settings.classifier.classify_country(fullname),
    sex: settings.classifier.classify_sex(firstname) }
  p data

  content_type :json
  data.to_json
end
