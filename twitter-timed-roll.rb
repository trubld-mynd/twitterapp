require 'rubygems'
require 'oauth'
require 'json'
require 'time'
require 'date'

require 'clockwork'
require './config/boot'
require './config/environment'



class TwitterTweet 
	def initialize()
		
		t = Time::new - (60 * 20)
		puts t

		## Establish Users
		names = ["PoisonSlammers", "TheWindSlayers", "PurpleSquirrels", "TheGhostSharks", "MightyCommandos", "DreamLightning"]
		users_list = Hash[names.map{|user| [user, 0]}]
		users_score = Hash[names.map{|user| [user, 0]}]
		users_last_time = Hash[names.map{|user| [user, 0]}]
		users_last_location = Hash[names.map{|user| [user, 0]}]

		## Establish Keywords
		keywords = ["pubquestbot", "drinks"]

		consumer_key = OAuth::Consumer.new(
		"lZLYSIi4dbgIN9yRzTcIeP8Fk",
		"3BqN9Qz9iVdYpPKJxXR0hjuaC1KXXPc03lIv02PyZGnXo5CRhR")
		access_token = OAuth::Token.new(
		"2776153651-zpSsnVPbMUhl34fWK2DdCmAhc2kG41aDPaZxiBP",
		"yiXJmkrdheEi4PNGu4IS7WcX1tC9y9hDR06EFqOtIg2Gg")
		baseurl = "https://api.twitter.com"

		users_list.each do |name, number|

		secondpath = "/1.1/statuses/user_timeline.json"
		query = URI.encode_www_form(
			"screen_name" => name,
			"count" => 10,
			)
		secondaddress = URI("#{baseurl}#{secondpath}?#{query}")
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
		        
		        if users_last_time[name] == 0 || (tweet_t > (users_last_time[name] + (60 * 20) )&& tweet_t < t)

		        puts tweet["user"]["screen_name"] + " - " + tweet["text"]
		        tweetout = nil
		        rollcount = 0
		        rollout = Array.new
		        tweetout = Array.new
		        # CHECK TWEET FOR KEY WORDS
		        if keywords.all?{|keyword| tweet["text"].to_s.downcase.include? keyword}
		        # If Key word found in tweet
		        puts "Key words found in " + tweet["user"]["screen_name"] + " - " + tweet["text"]
		        
		        ## Check if Media is included in tweet
		        ## If no pics, tweet "Pics or it didn't happen!"
		        pic = (tweet["entities"].has_key?("media"))
		        tweetout << "No dice! Pics or it didn't happen!" if (pic == false)
		        
		        ## SPLIT TWEET UP INTO WORDS 
			    words = tweet["text"].to_s.split(" ")
			    ## SEARCH FOR INTERGERS & GENERATE
		        ## RANDOM +/- 1 ROLLS
		        words.each do |word|
		            if word.to_i < 5 && word.to_i != 0 && rollcount == 0 && pic
		            roll = (word.to_i - 1 + rand(3))
		            users_score[name] += roll
		            
		            users_last_time[name] = tweet_t
		            tweetout << "Drink count is #{word.to_i}. Your roll is #{roll}!"
		            rollcount += 1
		            
		            else if word.to_i != 0 && rollcount == 0 && pic
		            roll = (3 + rand(3))
		            users_score[name] += roll
		            users_last_time[name] = tweet_t
		            tweetout << "Drink count is maxed at 4. Your roll is #{roll}!"
		            rollcount += 1
		            
		            # end of else if word.to_i != 0
		            end
		            #end of word.to_i < 5
		            end
		        # end of words.each
		        end
		        
		    ## TWEET BACK THE TWEETOUT
		    thirdpath    = "/1.1/statuses/update.json"
		    thirdaddress = URI("#{baseurl}#{thirdpath}")
		    request = Net::HTTP::Post.new thirdaddress.request_uri
		    request.set_form_data(
		      "status" => "@#{name} - #{tweetout[0]}",
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

every(2.minutes, 'Queueing twitter-tweet') { Delayed::Job.enqueue TwitterTweet.new }