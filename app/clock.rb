require 'clockwork'
require './config/boot'
require './config/environment'
module Clockwork
  handler do |job, time|
    puts "Running #{job}, at #{time}"
  end

  # handler receives the time when job is prepared to run in the 2nd argument
  # handler do |job, time|
  #   puts "Running #{job}, at #{time}"
  # end

  every(10.seconds,'Poll Transmission') {Torrent.delay(:queue => 'xmission').xmission_poller}
  #every(1.day, :at => '01:00'){Update TTDB}
  #every(1.day, :at => '02:00'){Update latest/next episode}
  #every(1.day, :at => '03:00'){do some more shit}
end
