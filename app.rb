require 'sinatra'
require 'sinatra/json'
require 'omniauth-ravelry'
require 'json'
require './helpers'

# dev gems
require 'pry' if development?
require 'pry-nav' if development?
require 'sinatra/reloader' if development?

configure do
  set :sessions, true
  set :session_secret, ENV['SESSION_SECRET']
  use OmniAuth::Builder do
    provider :ravelry, ENV['RAV_ACCESS'], ENV['RAV_SECRET']
  end
end

get '/' do
  redirect to('/auth/ravelry') unless current_user
  set_user unless @user
  json @user
end

post '/logout' do
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
