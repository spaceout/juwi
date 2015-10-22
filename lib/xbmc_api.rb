require 'net/telnet'
require 'logger'
require 'faye/websocket'
require 'eventmachine'
require 'jdb_helper'

class XbmcApi
  def initialize(logger = nil)
    @log = logger || Logger.new(STDOUT)
  end

  def self.process_message(message)
    parsed_message = JSON.parse(message)
    message_method = parsed_message["method"]
    if message_method == "VideoLibrary.OnScanStarted"
      puts "Scan for new video files initiated"
    elsif message_method == "VideoLibrary.OnScanFinished"
      puts "Scan for new video files complete"
    elsif message_method == "VideoLibrary.OnCleanStarted"
      puts "XBMC DB clean initiated"
    elsif message_method == "VideoLibrary.OnCleanFinished"
      puts "XBMC DB clean complete"
    elsif message_method == "VideoLibrary.OnUpdate"
      if parsed_message["params"]["data"]["playcount"] == nil && parsed_message["params"]["data"]["item"]["type"] == "episode"
        puts "New episode added to XBMC DB"
        #add_episode(parsed_message["params"]["data"]["item"]["id"])
      elsif parsed_message["params"]["data"]["item"]["type"] == "tvshow"
        puts "New TV show added to XBMC DB"
      elsif parsed_message["params"]["data"]["item"]["type"] = "movie"
        puts "New Movie added to XBMC DB"
      end
    elsif message_method == "VideoLibrary.OnRemove"
      if parsed_message["params"]["data"]["type"] == "movie"
        puts "Movie Removed from XBMC DB"
      elsif parsed_message["params"]["data"]["type"] == "episode"
        puts "Episode removed from XBMC DB"
        #remove_episode(parsed_message["params"]["data"]["id"])
      end
    end
  end

  def self.update_library
    compose_command("VideoLibrary.Scan")
  end

  def self.clean_library
    compose_command("VideoLibrary.Clean")
  end

  def self.compose_command(method)
    command = {
      "jsonrpc" => "2.0",
      "method" => "#{method}",
      "id" => 1
      }
    send_command(command.to_json)
  end

  def self.compose_query(method, data)
    command = {
      "jsonrpc"=>"2.0",
      "method"=>"#{method}",
      "params"=>
        {
        "data"=>"#{data}",
        "sender"=>"xbmc"
        }
      }
    send_command(command.to_json)
  end

  def self.send_command(command)
    EM.run {
      ws = Faye::WebSocket::Client.new("ws://#{Setting.get_value("xbmc_hostname")}:#{Setting.get_value("xbmc_port")}/")
      ws.onopen = lambda do |event|
        puts "successfully established connection"
        ws.send(command)
      end
      ws.onmessage = lambda do |event|
        puts event.data
        EM.stop
      end
      ws.onclose = lambda do |event|
        ws = nil
        puts "Disconnected from server"
        EM.stop
      end
    }
  end

  def self.wait_for_finished(command = nil)
    EM.run {
      ws = Faye::WebSocket::Client.new("ws://#{Setting.get_value("xbmc_hostname")}:#{Setting.get_value("xbmc_port")}/")
      ws.onopen = lambda do |event|
        puts "successfully established connection"
        ws.send(command) unless command.nil?
      end
      ws.onmessage = lambda do |event|
        puts event.data
        EM.stop if event.data.include?('Finished')
      end
      ws.onclose = lambda do |event|
        ws = nil
        puts "Disconnected from server"
        EM.stop
      end
    }
  end

end




#Methods =
# VideoLibrary.OnScanStarted
#VideoLibrary.OnScanFinished
#VideoLibrary.OnCleanStarted
#VideoLibrary.OnCleanFinished
#Episode Added
#{"jsonrpc":"2.0","method":"VideoLibrary.OnUpdate","params":{"data":{"item":{"id":19235,"type":"episode"}},"sender":"xbmc"}}i
#Episode Removed during clean
#{"jsonrpc":"2.0","method":"VideoLibrary.OnRemove","params":{"data":{"id":19235,"type":"episode"},"sender":"xbmc"}}
#Screensave activated
#{"jsonrpc":"2.0","method":"GUI.OnScreensaverDeactivated","params":{"data":false,"sender":"xbmc"}}
#screensaver deactivated
#{"jsonrpc":"2.0","method":"GUI.OnScreensaverDeactivated","params":{"data":false,"sender":"xbmc"}}
#starting show beg
#{"jsonrpc":"2.0","method":"Playlist.OnClear","params":{"data":{"playlistid":1},"sender":"xbmc"}}i
#{"jsonrpc":"2.0","method":"Playlist.OnAdd","params":{"data":{"item":{"id":19234,"type":"episode"},"playlistid":1,"position":0},"sender":"xbmc"}}
#{"jsonrpc":"2.0","method":"Player.OnPlay","params":{"data":{"item":{"id":19234,"type":"episode"},"player":{"playerid":1,"speed":1}},"sender":"xbmc"}}
#{"jsonrpc":"2.0","method":"Player.OnPause","params":{"data":{"item":{"id":19234,"type":"episode"},"player":{"playerid":1,"speed":0}},"sender":"xbmc"}}
#Starting show end
#Ending Show start
#{"jsonrpc":"2.0","method":"Player.OnStop","params":{"data":{"end":true,"item":{"id":19226,"type":"episode"}},"sender":"xbmc"}}
#{"jsonrpc":"2.0","method":"VideoLibrary.OnUpdate","params":{"data":{"item":{"id":19226,"type":"episode"},"playcount":1},"sender":"xbmc"}}
#Ending show end
