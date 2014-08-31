require 'rubygems'
require 'oauth'
require 'json'

require 'clockwork'
require './config/boot'
require './config/environment'

class TwitterTweet 
	def initialize()
		
			## Verify connection to Twitter API
		consumer_key = OAuth::Consumer.new(
		"",
		"")
		access_token = OAuth::Token.new(
		"",
		"")
		baseurl = "https://api.twitter.com"
		address = URI("#{baseurl}/1.1/account/verify_credentials.json")
		http = Net::HTTP.new address.host, address.port
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_PEER
		request = Net::HTTP::Get.new address.request_uri
		request.oauth! http, consumer_key, access_token
		http.start
		response = http.request request
		puts "The response status was #{response.code}"

		# Uses "/1.1/statuses/update.json" to send a tweet.
		# NOT "/1.1/statuses/user_timeline.json" to fetch 
		# total timeline, or "/1.1/statuses/show.json", which
		# takes an 'id' parameter and returns the
		# representation of a single Tweet.

	user_hash = {
		"PoisonSlammers" => 1854082506,
		"PurpleSquirrels" => 1854239119,
		"TheGhostSharks" => 1854159936,
		"TheWindSlayers" => 1854150030,
		"MightyCommandos" => 1854118404,
		"DreamLightning" => 1854106068
	}

		keywords = ["pubquestbot", "drinks"]

		user_hash.each do |name, number|

		secondpath = "/1.1/statuses/user_timeline.json"
		query = URI.encode_www_form(
			"screen_name" => name,
			"count" => 1,
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
		if response.code == '200' then
		  tweets = JSON.parse(response.body)
		    tweets.each do |tweet|
		        puts tweet["user"]["screen_name"] + " - " + tweet["text"]
		        rollcount = 0
		        rollout = Array.new
		        tweetout = Array.new
		        # CHECK TWEET FOR KEY WORDS
		        if keywords.all?{|str| tweet["text"].to_s.downcase.include? str}
		        # If Key word found in tweet
		        puts "Key words found in " + tweet["user"]["screen_name"] + " - " + tweet["text"]
		        ## SPLIT TWEET UP INTO WORDS 
			    words = tweet["text"].to_s.split(" ")
			    ## SEARCH FOR INTERGERS & GENERATE
		        ## RANDOM +/- 1 ROLLS
		        words.each do |word|
		            if word.to_i < 5 && word.to_i != 0 && rollcount == 0
		            roll = (word.to_i - 1 + rand(3))
		            rollout << roll
		            tweetout << "Drink count is #{word.to_i}. Your roll is #{roll}!"
		            puts tweetout
		            rollcount += 1
		            
		            else if word.to_i != 0 && rollcount == 0
		            roll = (3 + rand(3))
		            rollout << roll
		            tweetout << "Drink count is maxed at 4. Your roll is #{roll}!"
		            puts tweetout
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
		    
		        # end of if %w("pubquestbot").any?
		        end
		    
		    # end of tweets.each do |tweet|
		    end
		    
		# end of if response.code == '200'
		end

		#end of user_hash.each
		end

	# end of def initialize()
	end

# end of class TwitterTweet 
end

include Clockwork

every(2.minutes, 'Queueing twitter-tweet') { Delayed::Job.enqueue TwitterTweet.new }