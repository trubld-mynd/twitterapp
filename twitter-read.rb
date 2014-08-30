require 'rubygems'
require 'oauth'
require 'json'

class TwitterRead < PubquestBotTwitter

	user_hash = {
		"PoisonSlammers" => 1854082506,
		"PurpleSquirrels" => 1854239119,
		"TheGhostSharks" => 1854159936,
		"TheWindSlayers" => 1854150030,
		"MightyCommandos" => 1854118404,
		"DreamLightning" => 1854106068
	}

	user_hash.each do |twitterhandlename| {
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

		# Uses "/1.1/statuses/user_timeline.json" to fetch 
		# total timeline, verus /1.1/statuses/show.json, which
		# takes an 'id' parameter and returns the
		# representation of a single Tweet.



		path    = "/1.1/statuses/user_timeline.json"
		query   = URI.encode_www_form(
		    "screen_name" => twitterhandlename,
		    "count" => 10,
		)
		secondaddress = URI("#{baseurl}#{path}?#{query}")
		request = Net::HTTP::Get.new secondaddress.request_uri

		# Print data about a list of Tweets
		def print_timeline(tweets)
			tweets.each do |tweet|
			puts tweet["user"]["screen_name"] + " - " + tweet["text"]
			end
		end

		# Set up HTTP.
		http             = Net::HTTP.new secondaddress.host, secondaddress.port
		http.use_ssl     = true
		http.verify_mode = OpenSSL::SSL::VERIFY_PEER

		# Issue the request.
		request.oauth! http, consumer_key, access_token
		http.start
		response = http.request request

		# Parse and print the Tweet if the response code was 200
		tweets = nil
		if response.code == '200' then
		  tweets = JSON.parse(response.body)
		  print_timeline(tweets)
		end
		nil
	}
end