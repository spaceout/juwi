require 'clockwork'
require './config/boot'
require './config/environment'
module Clockwork
  handler do |job, time|
    puts "Running #{job}, at #{time}"
  end

  every(10.seconds,'Poll Transmission') {Torrent.delay(:queue => 'xmission').xmission_poller}
  every(1.day, :at => '01:00'){Tvshow.update}
#  every(1.day, :at => '06:00') do
#    require 'xbmc_api'
#    XbmcApi.compose_command("VideoLibrary.Scan")
#  end
#  every(1.day, :at => '06:15') do
#    require 'jdb_helper'
#    JdbHelper.sync_xdb_to_jdb
#  end
end
