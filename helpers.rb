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

def save_game(id, word, wins, losses)
  redis = get_connection
  redis.setex(id, 3600, { word: word, wins: wins, losses: losses, created: Time.now }.to_json)
  redis.quit
end
