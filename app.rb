require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'

set :database, "sqlite3:barber.sqlite"

class Client < ActiveRecord::Base
  validates :username, presence: true, length: { minimum: 3 }
  validates :phone, presence: true
  validates :datestamp, presence: true
  validates :color, presence: true
end

class Barber < ActiveRecord::Base
end

# login / logout
#----------------------------------

configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Sign in'
  end
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Need to be logged' + request.path
    halt erb(:login_form)
  end
end

get '/login/form' do
  erb :login_form
end

post '/login/attempt' do
  session[:identity] = params['username']
  where_user_came_from = session[:previous_url] || '/'
  redirect to where_user_came_from
end

get '/logout' do
  session.delete(:identity)
  redirect to '/'
end

before do
  @barbers = Barber.all
end

# root
#-------------------------------

get '/' do


  erb 'barber shop'
end

# visit.erb
#-------------------------------

get '/visit' do
  @c = Client.new

  erb :visit
end

post '/visit' do
  @c = Client.new params[:client]

  if !@c.save
    @error = @c.errors.full_messages.first
  else
    @message = @c.username + ', you signed'
  end

  erb :visit
end

# barbers.erb
#-------------------------------

get '/barbers' do
  @barbers = Barber.order 'created_at DESC'

  erb :barbers
end

# about.erb
#-------------------------------

get '/about' do

  erb :about
end

# contacts.erb
#-------------------------------

get '/contacts' do

  erb :contacts
end

# users.erb
#-------------------------------

get '/secure/place' do

  erb :users
end

# single barber
#-------------------------------

get '/barbers/:id' do
  @barber = Barber.find(params[:id])

  erb :barber
end

# users
#-------------------------------

before do
  @clients = Client.all
end

get '/secure/place' do
  @clients = Client.order('created_at DESC')

  erb :users
end

# single user
#------------------------------

get '/secure/place/:id' do
  @client = Client.find(params[:id])

  erb :client
end
