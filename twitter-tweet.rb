require 'rubygems'
require 'oauth'
require 'json'

require 'clockwork'
require './config/boot'
require './config/environment'

class TwitterTweet < PubquestBotTwitter

	user_hash = {
		"PoisonSlammers" => 1854082506,
		#"PurpleSquirrels" => 1854239119,
		#"TheGhostSharks" => 1854159936,
		"TheWindSlayers" => 1854150030,
		#"MightyCommandos" => 1854118404,
		"DreamLightning" => 1854106068
	}

	user_hash.each do |twitterhandlename| {
		baseurl = "https://api.twitter.com"
		path    = "/1.1/statuses/update.json"
		address = URI("#{baseurl}#{path}")
		request = Net::HTTP::Post.new address.request_uri
		request.set_form_data(
		  "status" => "@"+twitterhandlename+" Test tweet #1",
		)

		# Set up HTTP.
		http             = Net::HTTP.new address.host, address.port
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
	}
end

include Clockwork

every(2.minutes, 'Queueing twitter-tweet') { Delayed::Job.enqueue TwitterTweet.new }