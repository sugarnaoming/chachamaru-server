require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/json'
require_relative 'api'
require_relative '../crons/qiita_cron'

get '/api/hatebu/:entry/:category' do |entry, category|
  begin
    content_type :json
    json res_body = API::Hatebu.rss(entry: entry, category: category)
  rescue ArgumentError
    status 400
    body 'Entry or category or both arguments are incorrect'
  rescue StandardError
    status 400
    body 'It is an unexpected error'
  end
end

get '/api/qiita/rank/:period' do |period|
  content_type :json
  begin
    return json API::Qiita.daily_rank if period == 'daily'
    return json API::Qiita.weekly_rank if period == 'weekly'
    return json API::Qiita.popular if period == 'popular'
  rescue StandardError
    status 400
    body 'It is an unexpected error. If Perhaps it\'s a Rate Limit'
  end
end

# Error用URL
not_found do
  status 404
  body 'Not Found'
end

error do
  status 500
  body 'Internal Server Error'
end

# Crons操作用URL
get '/crons/qiita/get/daily' do
  return QiitaCron.get_daily_rank
end

get '/crons/qiita/get/weekly' do
  return QiitaCron.get_weekly_rank
end

get '/crons/qiita/del/daily' do
  return QiitaCron.delete_daily_rank
end

get '/crons/qiita/del/weekly' do
  return QiitaCron.delete_weekly_rank
end