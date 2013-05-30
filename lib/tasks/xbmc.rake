CONFIG = YAML.load_file(File.join(Rails.root,'/settings/settings.yml'))["config"]
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

  desc "This will start the XBMC listening daemon"
  task :daemon => :environment do
    require 'faye/websocket'
    require 'eventmachine'
    def xbmcconnect
      EM.run {
        ws = Faye::WebSocket::Client.new("ws://#{CONFIG["xbmc_hostname"]}:#{CONFIG["xbmc_port"]}/")
        ws.onopen = lambda do |event|
          puts "successfully established connection"
        end
        ws.onmessage = lambda do |event|
          puts "Received Data: #{event.data}"
          XbmcApi.process_message(event.data)
        end
        ws.onclose = lambda do |event|
          ws = nil
          puts "Disconnected from server, attempting to re-connect"
          EM.stop
        end
      }
    end
    while true
      puts "Attempting Connection"
      xbmcconnect
    end
  end
end






