require 'xbmc_daemon'

class DaemonsController < ApplicationController
  def start_daemon
    XbmcDaemon.start
    redirect_to '/'
  end

  def stop_daemon
    XbmcDaemon.stop
    redirect_to '/'
  end
end
