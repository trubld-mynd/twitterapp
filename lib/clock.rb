require 'clockwork'
require './config/boot'
require './config/environment'

include Clockwork

every(2.minutes, 'Queueing follow_thanks') { Delayed::Job.enqueue IntervalJob.new }