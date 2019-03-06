require "sinatra"
require "sinatra/config_file"
require "net/http"
require "twitter"

# Configuring Twitter client using credentials
config_file './config.yml'
client = Twitter::REST::Client.new do |config|
    config.consumer_key = settings.consumer_key
    config.consumer_secret = settings.consumer_secret
    config.access_token = settings.access_token
    config.access_token_secret = settings.access_token_secret
end

get "/search/" do
    client.user_timeline("le_santti", :count => 200).collect do |tweet|
        "#{tweet.user.screen_name}: #{tweet.text}\n\n"
    end
end