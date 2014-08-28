require 'clockwork'
require './config/boot'
require './config/environment'

include Clockwork

every(2.minutes, 'Queueing interval job') { Delayed::Job.enqueue IntervalJob.new }