desc "This will update the XBMC DB"
task :updateXBMC => :environment do


require 'faye/websocket'
require 'eventmachine'
def estab
  EM.run {
    ws = Faye::WebSocket::Client.new('ws://192.168.1.9:9090/')
    ws.onopen = lambda do |event|
      puts "successfully established connection"
      ws.send('{"jsonrpc":"2.0","method":"VideoLibrary.Scan","id":1}')
    end
    ws.onmessage = lambda do |event|
      if event.data == '{"id":1,"jsonrpc":"2.0","result":"OK"}'
        puts "Command  Received"
      elsif event.data == '{"jsonrpc":"2.0","method":"VideoLibrary.OnScanStarted","params":{"data":null,"sender":"xbmc"}}'
        puts "XBMCDB Update Started"
      elsif event.data == '{"jsonrpc":"2.0","method":"VideoLibrary.OnScanFinished","params":{"data":null,"sender":"xbmc"}}'
        puts "XBMCDB Update Complete"
        EM.stop
      else 
        puts "Something unexpected happened"
        EM.stop
      end
    end
    ws.onclose = lambda do |event|
      ws = nil
      puts "Disconnected from server"
      EM.stop
    end
  }
end
puts "Attempting Connection"
estab
end
