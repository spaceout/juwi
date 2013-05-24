require 'net/telnet'
require 'logger'

class XbmcApi
  def initialize(logger = nil)
    @log = logger || Logger.new(STDOUT)
  end

  def update_xbmc(hostname, port)
    @log.info "Begin Updating XBMC"
    telnethost = Net::Telnet::new("Host" => "#{hostname}","Port" => "#{port}", "Timeout" => 10,"Prompt" => /.*/, "Waittime" => 3)
    telnethost.cmd(%{{"jsonrpc":"2.0","method":"VideoLibrary.Scan","id":1}}) { |c| puts c}
    telnethost.close
    @log.info "XBMC Update is probably complete?"
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
      puts "New episode added to XBMC DB"
     # add_episode(parsed_message["params"]["data"]["item"]["id"])
    elsif message_method == "VideoLibrary.OnRemove"
      puts "Episode removed from XBMC DB"
      #remove_episode(parsed_message["params"]["data"]["id"])
    end
  end

  def add_episode(xdb_ep_id)
    puts xdb_ep_id
  end

  def remove_episode(xdb_ep_id)
    puts xdb_ep_id
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
