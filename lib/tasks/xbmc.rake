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

  desc "This will start the xbmc daemon fo realz"
  task :daemon_start => :environment do
    require 'xbmc_daemon'
    XbmcDaemon.start
  end

  desc "This is to test the XBMC Daemon in verbose mode"
  task :daemon_test => :environment do
    require 'faye/websocket'
    require 'eventmachine'
    require 'xbmc_api'
    def xbmcconnect
      EM.run {
        puts "ws://#{Settings.xbmc_hostname}:#{Settings.xbmc_port}/"
        ws = Faye::WebSocket::Client.new("ws://#{Settings.xbmc_hostname}:#{Settings.xbmc_port}/")
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
      sleep(5)
      xbmcconnect
    end
  end
end
