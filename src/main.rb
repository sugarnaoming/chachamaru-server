require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/json'
require_relative 'api'

get '/api/hatebu/:entry/:category' do |entry, category|
  begin
    res_body = API::HATEBU.rss(entry: entry, category: category)
    content_type :json
    json res_body
  rescue ArgumentError
    status 400
    body 'Entry or category or both arguments are incorrect'
  rescue StandardError
    status 400
    body 'It is an unexpected error'
  end
end