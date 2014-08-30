#!/usr/bin/env ruby
require 'Twitter'
# Create a read write application from :
# https://apps.twitter.com
# authenticate it for your account
# fill in the following
config = {consumer_key:'lZLYSIi4dbgIN9yRzTcIeP8Fk',  consumer_secret:'3BqN9Qz9iVdYpPKJxXR0hjuaC1KXXPc03lIv02PyZGnXo5CRhR',
access_token:'2776153651-zpSsnVPbMUhl34fWK2DdCmAhc2kG41aDPaZxiBP',  access_token_secret: 'yiXJmkrdheEi4PNGu4IS7WcX1tC9y9hDR06EFqOtIg2Gg'}
me = 'Pub Questbot' # to prevent DM yourself

class TwitterThanks < PubquestBotTwitter
 
Thread.new do
loop do
	begin
 
	rClient = Twitter::REST::Client.new config
	sClient = Twitter::Streaming::Client.new(config)
	sClient.user do |object|
		if object.is_a? Twitter::Streaming::Event and object.name==:follow
		user = object.source
			if user.name != me
			rClient.create_direct_message user, "Thanks for following me #{user.name} :)"
			puts "New follower : #{object.source.name}"
			end
		end
	end
	 
	rescue
	puts 'error occurred, sleeping for 5 seconds'
	sleep 5
	end
	end
	end
	 
	loop { sleep 5 }
end