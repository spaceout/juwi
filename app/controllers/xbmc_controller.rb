class XbmcController < ApplicationController
  def index

  end

  def play
    require 'xbmc_api'
    puts "BLERMTY #{params[:id]}"
    XbmcApi.play_episode(params[:id])
    redirect_to '/'
  end

  def pause

  end

  def stop

  end

  def update_library
    require 'xbmc_api'
    XbmcApi.compose_command("VideoLibrary.Scan")
    redirect_to '/'
  end

  def clean_library

  end

end
