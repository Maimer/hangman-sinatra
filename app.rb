require 'sinatra'
require_relative 'helpers'

enable :sessions

get '/' do
  #check to see if a game exists for this current session
  game = find_game(session.id)

  #if no game exists for this session, set wins and losses to 0
  if game.nil?
    @wins = 0
    @losses = 0
  else
    @wins = game[:wins]
    @losses = game[:losses]
  end

  #first check to see if a game exists for this session and if not make a new game
  #next check to see if the current game was redirected from a previous winning or losing game
  if game.nil? || game[:word] == game[:hidden]
    #picks a random word from the wordlist file, strips the newline character and makes it lowercase
    @word = File.readlines('wordlist.txt').sample.chomp.downcase
    #checks to make sure the word only contains letters and if not repicks a word
    while @word[/\A[a-zA-Z]+\z/] != @word
      @word = File.readlines('wordlist.txt').sample.chomp
    end
    @hidden = "_" * @word.length
    @letters = ""
    @guesses = 0
  #if a game exists that hasn't been completed, this will ensure page refeshes don't allow cheating
  else
    @word = game[:word]
    @hidden = game[:hidden]
    @letters = game[:letters]
    @guesses = game[:guesses]
    @wins = game[:wins]
    @losses = game[:losses]
  end

  save_game(session.id, @word, @hidden, @letters, @guesses, @wins, @losses)

  erb :index
end

post '/' do
  #check to see if a game exists for this current session
  game = find_game(session.id)

  #checks if parameters are from a finished game
  if params[:action] == "next" || game.nil?
    redirect '/'
  end

  guess = params[:guess].downcase

  #assign instance variables from game loaded from the database
  @next_game = false
  @word = game[:word]
  @letters = game[:letters]
  @wins = game[:wins]
  @losses = game[:losses]

  #checks to see if the player's guess was correct or incorrect
  #prevents submitted same letter multiple times
  if !@letters.include?(guess) && guess.length == 1
    if @word.include?(guess)
      @hidden = check_letter(@word, game[:hidden], guess)
      @guesses = game[:guesses]
    else
      @hidden = game[:hidden]
      @guesses = game[:guesses] + 1
    end
  else
    @hidden = game[:hidden]
    @guesses = game[:guesses]
  end

  #checks to see if whole word was guessed
  if guess.length > 1
    if guess == @word
      #if guessed correctly, assigns hidden word for win condition
      @hidden = @word
    else
      #if guessed incorrectly, assigns guesses for losing condition
      @guesses = 10
    end
  end

  #checks to see if the player correctly guessed the word and updates wins
  if @hidden == @word && @guesses < 10
    #prevents against resent post requests from the same game (stops cheating)
    if !@letters.include?(guess)
      @wins += 1
      @letters += guess
    end
    @next_game = true
    @button_text = "You Won!"
  #checks to see if the player had too many missed guesses and updates losses
  elsif @guesses >= 10
    #prevents against resent post requests from the same game (stops cheating)
    if !@letters.include?(guess)
      @losses += 1
      @letters += guess
    end
    @hidden = @word
    @next_game = true
    @button_text = "You Lost!"
  else
    @letters += guess
  end

  save_game(session.id, @word, @hidden, @letters, @guesses, @wins, @losses)

  erb :index
end
