namespace :xbmc do
  desc "This will update the XBMC DB"
  task :update => :environment do
    require 'xbmc_api'
    XbmcApi.compose_command("VideoLibrary.Scan")
  end

  desc "This will clean the XBMC DB"
  task :clean => :environment do
    require 'xbmc_api'
    XbmcApi.compose_command("VideoLibrary.Clean")
  end

  desc "This will check rando command with XBMC Daemon"
  task :rando => :environment do
    require 'xbmc_api'
    XbmcApi.compose_command("Player.GetActivePlayers")
  end
end
