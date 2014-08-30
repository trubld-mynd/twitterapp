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

			path    = "/1.1/statuses/update.json"
			secondaddress = URI("#{baseurl}#{path}")
			request = Net::HTTP::Post.new secondaddress.request_uri
			request.set_form_data(
			  "status" => "@PoisonSlammers Test tweet #1",
			)

			# Set up HTTP.
			http             = Net::HTTP.new secondaddress.host, secondaddress.port
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
		
	end
end

include Clockwork

every(2.minutes, 'Queueing twitter-tweet') { Delayed::Job.enqueue TwitterTweet.new }