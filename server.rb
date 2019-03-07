require "sinatra"
require "sinatra/config_file"
require "sinatra/json"
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

def get_mentions(tweet)
    mentions = []
    tweet.scan(/.*?(@\w+).*?/) {|x| mentions << x[0]}
    mentions
end

get "/layer" do
    mentions = []
    client.user_timeline(params[:user], :count => 100, :include_rts => false).collect do |tweet|
        get_mentions(tweet.text).each do |user_mentioned|
            filtered = mentions.select {|mention| mention["screen_name"] == user_mentioned}
            if filtered.length == 0 then 
                mentions << {"screen_name" => user_mentioned, "count" => 1}
            else 
                filtered[0]["count"] += 1 
            end
        end
    end
    json "connections" => mentions
end