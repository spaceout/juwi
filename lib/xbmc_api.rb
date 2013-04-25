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
end
