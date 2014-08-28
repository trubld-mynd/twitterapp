#!/usr/bin/env ruby
require 'Twitter'
# Create a read write application from :
# https://apps.twitter.com
# authenticate it for your account
# fill in the following
config = {consumer_key:'rXpb2PY9lKqgwnM8zkPKt3YZh',  consumer_secret:'2Qu3AU2Xw0NFu9M6MlONtBQ7LjKad2sP8GNZ7XNJhjvdjn2JSf',
access_token:'432276877-cpwQW4ZDAEKxH9YFS74O03yMUjinrCUni398ePAC',  access_token_secret: 'pjPYvTNKxb3bfqnIwewYU2x5UUTmHy6HvQeYnx1FmnsuH'}
me = 'Mike Dowling' # to prevent DM yourself

class IntervalJob
 
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