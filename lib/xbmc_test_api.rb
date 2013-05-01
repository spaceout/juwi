require 'faye/websocket'
require 'eventmachine'

def estab
  EM.run {
    ws = Faye::WebSocket::Client.new('ws://192.168.1.9:9090/')

    ws.onopen = lambda do |event|
      puts "successfully established connection"
      ws.send('{"jsonrpc": "2.0", "method": "Player.GetActivePlayers", "id": 1}')
    end

    ws.onmessage = lambda do |event|
      p [:message, event.data]
    end

    ws.onclose = lambda do |event|
      p [:close, event.code, event.reason]
      ws = nil
      EM.stop
    end
  }
end

puts "Attempting Connection"

while estab == nil
  puts "Error: re-trying connection"
end

