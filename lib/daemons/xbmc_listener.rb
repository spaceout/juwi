#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "developement"

root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exists?(File.join(root, 'config'))
Dir.chdir(root)

require File.join(root, "config", "environment")

$running = true
Signal.trap("TERM") do 
  $running = false
end

while($running) do
  require 'faye/websocket'
  require 'eventmachine'
  require 'xbmc_api'

  def xbmcconnect
    EM.run {
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
  xbmcconnect
  while true
    puts "Attempting Connection"
    sleep(5)
    xbmcconnect
  end
end
