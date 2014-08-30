require 'clockwork'
require './config/boot'
require './config/environment'

include Clockwork

every(2.minutes, 'Queueing twitter-read') { Delayed::Job.enqueue TwitterRead.new }
