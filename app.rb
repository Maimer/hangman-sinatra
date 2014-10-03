require 'sinatra'
require 'faker'
require_relative 'helpers'

enable :sessions

get '/' do
  @word = [Faker::Hacker.noun, Faker::Hacker.verb].sample
  while @word.include?("_")
    @word = [Faker::Hacker.noun, Faker::Hacker.verb].sample
  end
  @hidden = "_" * @word.length
  @letters = ""
  @guesses = 0

  game = find_game(session.id)
  if game.nil?
    @wins = 0
    @losses = 0
  else
    @wins = game[:wins]
    @losses = game[:losses]
  end

  save_game(session.id, @word, @hidden, @letters, @guesses, @wins, @losses)

  erb :index
end

post '/' do
  if params[:action] == "next"
    redirect '/'
  end

  game = find_game(session.id)
  guess = params[:guess].downcase

  if game.nil? || !('a'..'z').include?(guess)
    redirect '/'
  end

  @nextgame = false
  @word = game[:word]
  @letters = game[:letters] + guess
  @wins = game[:wins]
  @losses = game[:losses]

  if @word.include?(guess)
    @hidden = check_letter(@word, game[:hidden], guess)
    @guesses = game[:guesses]
  else
    @hidden = game[:hidden]
    @guesses = game[:guesses] + 1
  end

  if @hidden == @word
    @wins += 1
    save_game(session.id, @word, @hidden, "", 0, @wins, @losses)
    @nextgame = "You Won!"
  end

  if @guesses >= 10
    @losses += 1
    @hidden = @word
    save_game(session.id, @word, @hidden, "", 0, @wins, @losses)
    @nextgame = "You Lost!"
  end

  save_game(session.id, @word, @hidden, @letters, @guesses, @wins, @losses)

  erb :index
end
