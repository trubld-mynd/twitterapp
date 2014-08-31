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
		    "lZLYSIi4dbgIN9yRzTcIeP8Fk",
		    "3BqN9Qz9iVdYpPKJxXR0hjuaC1KXXPc03lIv02PyZGnXo5CRhR")
			access_token = OAuth::Token.new(
		    "2776153651-zpSsnVPbMUhl34fWK2DdCmAhc2kG41aDPaZxiBP",
		    "yiXJmkrdheEi4PNGu4IS7WcX1tC9y9hDR06EFqOtIg2Gg")
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
				"TheWindSlayers" => 1854150030
			}

			user_hash.each do |name, number|

				secondpath = "/1.1/statuses/user_timeline.json"
				query = URI.encode_www_form(
	    			"screen_name" => name,
					"count" => 1,
					)
				secondaddress = URI("#{baseurl}#{secondpath}?#{query}")
				request = Net::HTTP::Get.new secondaddress.request_uri

				def print_timeline(tweets)
				  tweets.each do |tweet|
				    puts tweet["user"]["screen_name"] + " - " + tweet["text"]
				    end
				end

				http             = Net::HTTP.new secondaddress.host, secondaddress.port
				http.use_ssl     = true
				http.verify_mode = OpenSSL::SSL::VERIFY_PEER

				request.oauth! http, consumer_key, access_token
				http.start
				response = http.request request

				tweets = nil
				if response.code == '200' then
				  tweets = JSON.parse(response.body)
				  print_timeline(tweets)
				end
			
			## SEARCH TWEET FOR MARKERS
			markers = ["@pubquestbot", "d"]
			tweets.select do |phrase|
				if markers.all? {|marker| phrase.include? marker }
					## SPLIT TWEET UP INTO WORDS 
						words = tweets.split(" ")
					## SEARCH FOR INTERGERS & GENERATE
					## RANDOM +/- 1 TWEETOUTS
							words.each do |word|
								if word.is_i? 
									case integerlength
									when word <= 4
										puts word
										tweetout = word -1 + rand(2)
									when word > 4
										tweetout = "Bad number! Must be <=4!"
									else
										puts "#"
									end
								else
									puts "#"
								end
							end

					## TWEET BACK THE TWEETOUT
					thirdpath    = "/1.1/statuses/update.json"
					thirdaddress = URI("#{baseurl}#{thirdpath}")
					request = Net::HTTP::Post.new thirdaddress.request_uri
					request.set_form_data(
					  "status" => "@#{name} - #{tweetout}",
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
				else
					puts "no markers"
				end
			end	
		end
	end
end

include Clockwork

every(2.minutes, 'Queueing twitter-tweet') { Delayed::Job.enqueue TwitterTweet.new }