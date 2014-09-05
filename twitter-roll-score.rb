require 'rubygems'
require 'oauth'
require 'json'
require 'time'
require 'date'

require 'clockwork'
require './config/boot'
require './config/environment'

class TwitterDM
    def initialize()
        t = Time::new
        $t_end = Time.new(2014,9,5,23,00,0,"+10:00")

        directmessages = ["Welcome to the Pub Quest 2014! Use twitter to play by texting your drink count at each pub (max 4) WITH A PHOTO to @pubquestbot.", 
            "For example, if you've had 3 drinks, take a photo of your team with the drinks, and tweet '@pubquestbot 3 drinks'. Don't forget the pic!", 
            "pubquestbot will randomly +/-1 to your drink count to determine your roll on the gameboard. Always go where you're told. No cheating!", 
            "You can only post to pubquestbot every 20 minutes. If you do it any more often there may be some nasty surprises in store for you...", 
            "The winner will be the first to the final pub, OR the team that gets the furtherest in 2.5 hours. If you want to keep track of the teams...", 
            "...or check the rules, check out the website at http://www.pubquest.info", 
            "LET THE GAMES BEGIN!",
            "The pubquest is over! Come to the final pub for celebratory drinks!"]

## Verify connection to Twitter API
consumer_key = OAuth::Consumer.new(
"lZLYSIi4dbgIN9yRzTcIeP8Fk",
"3BqN9Qz9iVdYpPKJxXR0hjuaC1KXXPc03lIv02PyZGnXo5CRhR")
access_token = OAuth::Token.new(
"2776153651-zpSsnVPbMUhl34fWK2DdCmAhc2kG41aDPaZxiBP",
"yiXJmkrdheEi4PNGu4IS7WcX1tC9y9hDR06EFqOtIg2Gg")
baseurl = "https://api.twitter.com"

## Run the following script for each message 
## in the directmessages array above
message_to_tweet = nil
directmessages.each do |message|

    ## Search past pubquestbot tweets for direct messages
    ## Using the same search method as to establish
    ## users past pub instructions
    firstpath = "/1.1/statuses/user_timeline.json"
    locationquery = URI.encode_www_form(
        "screen_name" => "pubquestbot",
        "count" => 200,
        )
    firstaddress = URI("#{baseurl}#{firstpath}?#{locationquery}")
    request = Net::HTTP::Get.new firstaddress.request_uri

    http             = Net::HTTP.new firstaddress.host, firstaddress.port
    http.use_ssl     = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    request.oauth! http, consumer_key, access_token
    http.start
    response = http.request request

    pasttweets = nil
    if response.code == '200' then
      pasttweets = JSON.parse(response.body)
        pasttweets.reverse_each do |pasttweet|
        ## set message_to_tweet if don't find message in pasttweets
        message_to_tweet = case message
        when pasttweet then break
        when directmessages.last then message if t > $t_end
        else message
        # end of message_to_tweet case
        end 

        # end of bottweets.reverse_each
        end
    # end of response.code == '200'
    end    

## Post direct tweets for pubquest instructions
## Use same script for outgoing Tweets
## As section 3 of the search & tweet.

            thirdpath    = "/1.1/statuses/update.json"
            thirdaddress = URI("#{baseurl}#{thirdpath}")
            request = Net::HTTP::Post.new thirdaddress.request_uri
            request.set_form_data(
              "status" => message_to_tweet,
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
            tweet = nil
            if response.code == '200' then
              tweet = JSON.parse(response.body)
              puts "Successfully sent #{tweet["text"]}"
            else
              puts "Could not send the Tweet! " +
              "Code:#{response.code} Body:#{response.body}"
            end
            sleep 5
        # end of directmessages.each do |message|
        end
    # end of def initialize()
    end
# end of class TwitterDM 
end
#####################################
#####################################
#####################################
class TwitterTweet
    def initialize()

t = Time::new
puts t

## Establish Users
 
names = ["PoisonSlammers", "TheWindSlayers", "PurpleSquirrels", "TheGhostSharks", "MightyCommandos", "DreamLightning"]
users_list = Hash[names.map{|user| [user, 0]}]
users_score = Hash[names.map{|user| [user, 0]}]
users_last_time = Hash[names.map{|user| [user, 0]}]
users_last_location = Hash[names.map{|user| [user, 0]}]
puts "users_score = " + users_score.to_s

## Verify connection to Twitter API
consumer_key = OAuth::Consumer.new(
"lZLYSIi4dbgIN9yRzTcIeP8Fk",
"3BqN9Qz9iVdYpPKJxXR0hjuaC1KXXPc03lIv02PyZGnXo5CRhR")
access_token = OAuth::Token.new(
"2776153651-zpSsnVPbMUhl34fWK2DdCmAhc2kG41aDPaZxiBP",
"yiXJmkrdheEi4PNGu4IS7WcX1tC9y9hDR06EFqOtIg2Gg")
baseurl = "https://api.twitter.com"

## Establish Keywords
keywords = ["pubquestbot", "drinks"]

## Establish Bar Locations
bars = [0,1,2,6,2,5,6,7,11,9,10,11,7,13]
barnames = ["Start", "Bar 1", "Bar2", "Bar 333", "Bar 4", "Bar Five", "Bar666", "Bar 7", "Bar Eight", "Nine9", "Ten", "Bar Eleven", "Bar 12", "Bar 13"]
barsnls = ["Start","A slow start to ","Go on to ","LADDER! Go straight to ","SNAKE! Go back to ","Move on to ","Head to ","Go on to ","LADDER! Go straight to ","Dance on to ","Rock on to ","Nearly there! Go to ","SNAKE! (Oooh so close!) Go back to ","The end in sight! Go to "]


## Get User current position from Pubquestbot's 
## previous instruction tweets 

firstpath = "/1.1/statuses/user_timeline.json"
locationquery = URI.encode_www_form(
	"screen_name" => "pubquestbot",
	"count" => 20,
	)
firstaddress = URI("#{baseurl}#{firstpath}?#{locationquery}")
request = Net::HTTP::Get.new firstaddress.request_uri

http             = Net::HTTP.new firstaddress.host, firstaddress.port
http.use_ssl     = true
http.verify_mode = OpenSSL::SSL::VERIFY_PEER

request.oauth! http, consumer_key, access_token
http.start
response = http.request request

bottweets = nil
if response.code == '200' then
  bottweets = JSON.parse(response.body)
    bottweets.reverse_each do |bottweet|
    puts bottweet["user"]["name"] + " - " + bottweet["text"]
    ## Identify User from bottweet
    to_user = bottweet["in_reply_to_screen_name"]
    to_user_freeze = to_user.freeze
    if to_user != nil && to_user != ""
        ## SPLIT TWEET UP INTO WORDS 
    	botwords = bottweet["text"].to_s.split(" ")
    	lastpub = botwords.last.to_i
        users_score[to_user_freeze] = lastpub
    # if to_user != nil
    end
    # end of bottweets.reverse_each
    end
# end of response.code == '200'
end

puts users_score

## Run the search & tweet script for all 
## users in the user_list

users_list.each do |name, number|

## Search User Timelines

secondpath = "/1.1/statuses/user_timeline.json"
userquery = URI.encode_www_form(
	"screen_name" => name,
	"count" => 15,
	)
secondaddress = URI("#{baseurl}#{secondpath}?#{userquery}")
request = Net::HTTP::Get.new secondaddress.request_uri

http             = Net::HTTP.new secondaddress.host, secondaddress.port
http.use_ssl     = true
http.verify_mode = OpenSSL::SSL::VERIFY_PEER

request.oauth! http, consumer_key, access_token
http.start
response = http.request request

tweets = nil
tweet_t = nil
if response.code == '200' then
  tweets = JSON.parse(response.body)
    tweets.reverse_each do |tweet|
        tweetout = nil
        rollcount = 0
        rollout = Array.new
        tweetout = Array.new        
        ## Get tweet location (if available) and push to 
        ## users_last_location hash
        tweet_geo = tweet["coordinates"]
        users_last_location[name] = tweet_geo if (tweet_geo != "null")
        
        ## Set time of tweet to variable tweet_t
        time_arr = (tweet["created_at"].to_s.split(" "))
        time_time = (time_arr[3].to_s.split(":"))
        time_arr.delete_at(3)
        time_arr.insert(3, time_time[0].to_i, time_time[1].to_i, time_time[2].to_i)
        tweet_t = Time.new(time_arr[7].to_i,Date::ABBR_MONTHNAMES.index(time_arr[1]),time_arr[2].to_i,time_arr[3],time_arr[4],time_arr[5])
        
        if users_last_time[name] == 0 || (tweet_t > (users_last_time[name] + (60 * 20))) 

            if tweet_t < ($t_end - 160) && (users_score[name]) == 0
                tweetout << "@#{name} Go to the first bar at #{barnames[1]} - # 1"
            end
        ## puts tweet["user"]["screen_name"] + " - " + tweet["text"]
        ## ^ Removed because list of tweets is flooding heroku logs

        # CHECK TWEET FOR KEY WORDS
        if keywords.all?{|keyword| tweet["text"].to_s.downcase.include? keyword}
        # If Key word found in tweet
        puts "Key words found in " + tweet["user"]["screen_name"] + " - " + tweet["text"]
        
        ## Check if Media is included in tweet
        ## If no pics, tweet "Pics or it didn't happen!"
        pic = (tweet["entities"].has_key?("media"))
        tweetout << "@#{name} No dice! Pics or it didn't happen!" if (pic == false)
        
        ## SPLIT TWEET UP INTO WORDS 
	    words = tweet["text"].to_s.split(" ")
	    ## SEARCH FOR INTERGERS & GENERATE
        ## RANDOM +/- 1 ROLLS
        words.each do |word|
            if word.to_i < 5 && word.to_i != 0 && rollcount == 0 && pic
            botroll = - 1 + rand(3)
            roll = (word.to_i + botroll)
            botroll_talk = case botroll
                when -1 then ", but Pubquestbot takes 1 off you! "
                when 1 then ", but Pubquestbot gives you +1! "
                else ". "
            end
            go_to_bar = bars[(users_score[name] + roll)]
            go_to_barname = barnames[go_to_bar]
            go_to_bartalk = barsnls[(users_score[name] + roll)]

            tweetout << "@#{name} You're on #{users_score[name]} and drank #{word.to_i}#{botroll_talk}You roll #{roll} to ##{(users_score[name] + roll)} - #{go_to_bartalk}#{go_to_barname} - # #{go_to_bar}"
            users_score[name] = go_to_bar.to_i
            users_last_time[name] = tweet_t
            rollcount += 1
            
            else if word.to_i != 0 && rollcount == 0 && pic
            
            botroll = - 1 + rand(2)
            roll = (word.to_i + botroll)
            botroll_talk = case botroll
                when -1 then ", and Pubquestbot takes 1! "
                when 1 then " Pubquestbot gives you +1! "
                else ". "
            end
            go_to_bar = bars[(users_score[name] + roll)]
            go_to_barname = barnames[go_to_bar]
            go_to_bartalk = barsnls[(users_score[name] + roll)]
            users_score[name] = go_to_bar.to_i
            users_last_time[name] = tweet_t
            tweetout << "@#{name} Drink count is maxed at 4#{botroll_talk}Your roll is #{roll} to ##{(users_score[name] + roll)} - #{go_to_bartalk}#{go_to_barname} - # #{go_to_bar}"
            rollcount += 1
            
            # end of else if word.to_i != 0
            end
            #end of word.to_i < 5
            end
        # end of words.each
        end
        
        puts tweetout
        
		    ## TWEET BACK THE TWEETOUT
		    thirdpath    = "/1.1/statuses/update.json"
		    thirdaddress = URI("#{baseurl}#{thirdpath}")
		    request = Net::HTTP::Post.new thirdaddress.request_uri
		    request.set_form_data(
		      "status" => "#{tweetout[0]}",
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
		    tweet = nil
		    if response.code == '200' then
		      tweet = JSON.parse(response.body)
		      puts "Successfully sent #{tweet["text"]}"
		    else
		      puts "Could not send the Tweet! " +
		      "Code:#{response.code} Body:#{response.body}"
		    end
		    
		     # end of if keywords.all?{|str|...
		    end
		    
		    # end of if tweet_t < users_last_time[name] && tweet_t < t
		    end
		    
		    # end of tweets.each do |tweet|
		    end
		    
		## sleep for 3 seconds, so don't get 429 code
		    sleep 3
		    
		# end of if response.code == '200'
		end

		#end of users.list.each
		end

		puts users_score
		puts users_last_time
		puts users_last_location
	# end of def initialize()
	end

# end of class TwitterTweet 
end

include Clockwork

every(2.minutes, 'Queueing instruction-tweets') { Delayed::Job.enqueue TwitterDM.new }
every(2.minutes, 'Queueing twitter-tweet') { Delayed::Job.enqueue TwitterTweet.new }
