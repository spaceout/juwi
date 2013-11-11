ENV['RAILS_ENV'] = ARGV.first || ENV['RAILS_ENV'] || 'development'
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'faye/websocket'
require 'eventmachine'
require 'xbmc_api'

def xbmcconnect
config = YAML.load_file(File.join(Rails.root,'/settings/settings.yml'))["config"]
  EM.run {
    ws = Faye::WebSocket::Client.new("ws://#{config["xbmc_hostname"]}:#{config["xbmc_port"]}/")
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
xbmcconnect
while true
  puts "Attempting Connection"
  sleep(5)
  xbmcconnect
end
