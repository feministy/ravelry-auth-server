require 'sinatra'
require 'sinatra/json'
require 'omniauth-ravelry'
require 'json'
require 'net/http'
require 'oauth'
require './helpers'

# dev gems
require 'pry' if development?
require 'pry-nav' if development?
require 'sinatra/reloader' if development?

configure :development do
  URL_BASE = 'http'
end

configure :production do
  URL_BASE = 'https'
end

configure do
  set :sessions, true
  set :session_secret, ENV['SESSION_SECRET']
  use OmniAuth::Builder do
    provider :ravelry, ENV['RAV_ACCESS'], ENV['RAV_SECRET']
  end
end

get '/' do
  redirect to('/auth/ravelry') unless current_user?
  set_user unless @user
  json @user
end

get '/logout' do
  clear_session
end

get '/session' do
  check_session
end

get '/auth/ravelry/callback' do
  set_session
  set_user
  json @user
end

get '/api/*' do
  url = params['splat'][0]
  uri = URI("#{URL_BASE}://api.ravelry.com/#{url}")
  req = Net::HTTP::Get.new(uri)

  consumer = OAuth::Consumer.new(session[:consumer][:key], session[:consumer][:secret], { site: "#{URL_BASE}://api.ravelry.com"})
  access_token = OAuth::AccessToken.new(consumer, session[:token][:token], session[:token][:secret]) 
  consumer.sign!(req, access_token)

  res = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }

  json JSON.parse(res.body)
end
