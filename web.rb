require 'sinatra'
require 'nbayes'
require 'ngram'
require 'csv'
require "sinatra/reloader" if development?
require 'json'

configure :production do
  require 'newrelic_rpm'
end

configure do
  nbayes_s = NBayes::Base.new
  nbayes_c = NBayes::Base.new
  ngram = NGram.new({:size=>3, :padchar=>' '})

  reader = CSV.open("athletes.csv", "r")
  reader.shift
  reader.each do |row|
    ng = ngram.parse(row[0].downcase).flatten
    nbayes_c.train(ng, row[2])

    /(^.*[A-Z]) ([A-Z][a-z].*)/ =~ row[0].gsub(/'/, '')
    if $1 != nil && $2 != nil
      firstname = $2
      ng = ngram.parse(firstname.downcase).flatten
      nbayes_s.train(ng, row[1])
    end
  end
  reader.close

  set :nbayes_s, nbayes_s
  set :nbayes_c, nbayes_c
  set :ngram, ngram
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
  #puts "#{firstname}:#{fullname}"
  if firstname.empty? or fullname.empty?
    status 400
  end

  s = settings.nbayes_s.classify(settings.ngram.parse(firstname).flatten)
  c = settings.nbayes_c.classify(settings.ngram.parse(fullname).flatten)
  #p settings.ngram.parse(fullname)
  # sort array by probability then convert to hash
  c_hash = Hash[*c.sort{|a, b| b[1] <=> a[1]}[0..4].flatten]
  data = { country: c_hash, sex: s}

  content_type :json
  data.to_json
end
