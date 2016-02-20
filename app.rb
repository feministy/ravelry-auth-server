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
  session[:redirect] = params['redirect']
  redirect to('/auth/ravelry')
end

get '/logout' do
  clear_session(params['username'])
end

get '/session' do
  check_session(params['username'], params['token'])
end

get '/auth/ravelry/callback' do
  user = set_session
  redirect_url = session[:redirect]
  session[:redirect] = nil
  user_params = "user=#{user[:username]}&name=#{user[:first_name]}&token=#{user[:token]}"
  redirect to "#{redirect_url}?#{user_params}"
end

get '/api/*' do
  # pass username and token
  # verify that the token matches the username current session
  # make call using secret
  url = params['splat'][0]
  uri = URI("#{URL_BASE}://api.ravelry.com/#{url}")
  req = Net::HTTP::Get.new(uri)

  consumer = OAuth::Consumer.new(session[:consumer][:key], session[:consumer][:secret], { site: "#{URL_BASE}://api.ravelry.com"})
  access_token = OAuth::AccessToken.new(consumer, session[:token][:token], session[:token][:secret]) 
  consumer.sign!(req, access_token)

  res = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }

  json JSON.parse(res.body)
end
