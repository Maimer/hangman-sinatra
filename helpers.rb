require 'json'
require 'redis'

def get_connection
  begin
    if ENV.has_key?("REDISCLOUD_URL")
      connection = Redis.new(url: ENV["REDISCLOUD_URL"])
    else
      connection = Redis.new
    end
  ensure
    connection.quit
  end
end

def find_game(id)
  redis = get_connection
  game = JSON.parse(redis.get(id), symbolize_names: true)
  redis.quit
  game
end

def save_game(id, word, hidden, guesses, wins, losses)
  redis = get_connection
  redis.setex(id, 3600, { word: word,
                          hidden: hidden,
                          guesses: guesses,
                          wins: wins,
                          losses: losses }.to_json)
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
