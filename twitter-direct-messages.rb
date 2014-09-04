require 'rubygems'
require 'oauth'
require 'json'
require 'time'
require 'date'

require 'clockwork'
require './config/boot'
require './config/environment'

class TwitterMessage
    def initialize()

## Establish Users
 
names = ["PoisonSlammers", "TheWindSlayers", "PurpleSquirrels", "TheGhostSharks", "MightyCommandos", "DreamLightning"]
users_list = Hash[names.map{|user| [user, 0]}]
directmessages = ["Welcome to the Pub Quest 2014! Use twitter to play by texting your drink count at each pub (max 4) WITH A PHOTO to @pubquestbot.", "For example, if you've had 3 drinks, take a photo of your team with the drinks, and tweet '@pubquestbot 3 drinks'. Don't forget the pic!", "pubquestbot will randomly +/-1 to your drink count to determine your roll on the gameboard. Always go where you're told. No cheating!", "You can only post to pubquestbot every 20 minutes. If you do it any more often there may be some nasty surprises in store for you...", "The winner will be the first to the final pub, OR the team that gets the furtherest in 2.5 hours. If you want to keep track of the teams...", "...or check the rules, check out the website at http://www.pubquest.info Now go for it!!"]

## Verify connection to Twitter API
consumer_key = OAuth::Consumer.new(
"lZLYSIi4dbgIN9yRzTcIeP8Fk",
"3BqN9Qz9iVdYpPKJxXR0hjuaC1KXXPc03lIv02PyZGnXo5CRhR")
access_token = OAuth::Token.new(
"2776153651-zpSsnVPbMUhl34fWK2DdCmAhc2kG41aDPaZxiBP",
"yiXJmkrdheEi4PNGu4IS7WcX1tC9y9hDR06EFqOtIg2Gg")
baseurl = "https://api.twitter.com"

## Do the following script for users_list.each do |name|

users_list.each do |name|
    directmessages.each do |message|
## Establish connection to Twitter Direct Messages server

   ## SEND OUT DIRECT MESSAGES TO ALL USERS
    thirdpath    = "/1.1/direct_messages/new.json"
    thirdaddress = URI("#{baseurl}#{thirdpath}")
    request = Net::HTTP::Post.new thirdaddress.request_uri
    request.set_form_data(
      "screen_name" => name,
    "text" => message,
    )
    
    # Set up HTTP.
    http             = Net::HTTP.new thirdaddress.host, thirdaddress.port
    http.use_ssl     = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    
    # Issue the request.
    request.oauth! http, consumer_key, access_token
    http.start
    response = http.request request
    
    # Parse and print the Tweet if the response code was 200
    directtweet = nil
    if response.code == '200' then
      directtweet = JSON.parse(response.body)
      puts "Successfully sent #{directtweet["text"]}"
    else
      puts "Could not send the Tweet! " +
      "Code:#{response.code} Body:#{response.body}"
    end
    
		## sleep for 3 seconds, so don't get 429 code
		    sleep 3
		    
		# end of if response.code == '200'
		end

        #end of directmessages.each
        end

		#end of users_list.each
		end

	# end of def initialize()
	end

# end of class TwitterTweet 
end

include Clockwork

every(1.day, 'Queueing twitter-direct-messages', :at => '00:00') { Delayed::Job.enqueue TwitterMessage.new }