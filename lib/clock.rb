require 'clockwork'
require './config/boot'
require './config/environment'

include Clockwork

every(2.minutes, 'Queueing twitter-tweet') { Delayed::Job.enqueue TwitterTweet.new }
