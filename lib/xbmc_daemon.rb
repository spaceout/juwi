class XbmcDaemon
  def self.start
    xbmcd = Daemons::Rails::Monitoring.controller("xbmc_listener.rb")
    xbmcd.start
    return xbmcd.status
  end
  def self.stop
    xbmcd = Daemons::Rails::Monitoring.controller("xbmc_listener.rb")
    xbmcd.stop
    return xbmcd.status
  end
  def self.status
    xbmcd = Daemons::Rails::Monitoring.controller("xbmc_listener.rb")
    return xbmcd.status
  end
end
