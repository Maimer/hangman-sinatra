require 'json'
require 'redis'

def get_connection
  begin
    if ENV.has_key?("REDIS_URL")
      connection = Redis.new(url: ENV["REDIS_URL"])
    else
      connection = Redis.new
    end
  ensure
    connection.quit
  end
end

def find_game(id)
  redis = get_connection
  game_check = redis.get(id)
  return nil if game_check.nil?
  game = JSON.parse(game_check, symbolize_names: true)
  redis.quit
  game
end

def save_game(id, word, hidden, letters, guesses, wins, losses)
  redis = get_connection
  redis.set(
    id,
    {
      word: word,
      hidden: hidden,
      letters: letters,
      guesses: guesses,
      wins: wins,
      losses: losses,
    }.to_json
  )
  redis.quit
end

def check_letter(word, hidden, letter)
  word.length.times do |num|
    if word[num] == letter
      hidden[num] = letter
    end
  end
  hidden
end
