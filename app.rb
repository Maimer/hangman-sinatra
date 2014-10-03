require 'sinatra'
require 'random_word_generator'
require_relative 'helpers'

enable :sessions

require 'pry'

get '/' do
  @word = RandomWordGenerator.of_length(rand(6)+7)
  @hidden = "_" * @word.length
  save_game(session.id, @word, @hidden, 0, 0, 0)

  erb :index
end

post '/' do
  game = find_game(session.id)
  @word = game[:word]

  if @word.include?(params[:guess])
    @hidden = check_letter(@word, game[:hidden], params[:guess])
    @guesses = game[:guesses]
  else
    @hidden = game[:hidden]
    @guesses = game[:guesses] += 1
  end

  if @hidden == @word
    #win
  end

  if @guesses >= 10
    #lose
  end

  save_game(session.id, @word, @hidden, @guesses, 0, 0)

  erb :index
end
