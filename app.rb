require 'sinatra'
require 'random_word_generator'
require_relative 'helpers'

enable :sessions

require 'pry'

get '/' do
  id = session.id
  word = RandomWordGenerator.of_length(rand(6)+7)

  erb :index
end

post '/' do

end
