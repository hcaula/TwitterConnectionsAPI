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

# Link to get profile image: "https://avatars.io/twitter/le_santti/medium"

get "/connections" do
    user_sname = params[:user]
    user = {}
    mentions = []
    begin
        client.user_timeline(user_sname, :count => 200).collect do |tweet|
        user = tweet.user
        tweet.user_mentions.each do |mention|
            filtered = mentions.select {|f| f["screen_name"] == mention.screen_name}
            if filtered.length == 0 then 
                mentions << {
                    "screen_name" => mention.screen_name,
                    "user_id" => mention.id.to_s,
                    "name" => mention.name,
                    "count" => 1
                }
            else filtered[0]["count"] += 1 end
        end
    end
    rescue Twitter::Error => e
        return json ({"status" => e.code, "message" => e.message})
    end
    
    return json ({
        "connected_to" => {
            "screen_name": user["screen_name"],
            "user_id": user["id"].to_s
        },
        "connections" => mentions
    })
end