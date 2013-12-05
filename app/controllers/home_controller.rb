class HomeController < ApplicationController
  CONFIG = YAML.load_file(File.join(Rails.root,'/settings/settings.yml'))["config"]
  def index
    require 'xmission_api'
    require 'file_manipulator'
    require 'xbmc_daemon'
    @tvshows = Tvshow.all.sort_by(&:ttdb_show_title)
    @episodes = Episode.where("ttdb_season_number > 0 AND ttdb_episode_airdate < ?", DateTime.now)
    @completeness = (100 - (@episodes.missing.count.to_f  / @episodes.count.to_f) * 100).round(2)
    @finished_dir = FileManipulator.list_dir(CONFIG["renamedir"])
    xmission = XmissionApi.new(:username => CONFIG["transmission_user"],:password => CONFIG["transmission_password"],:url => CONFIG["transmission_url"]) 
    @transmission_dls = xmission.all
    @xbmc_daemon_status = XbmcDaemon.status
  end
  def rename
    require 'xmlsimple'
    require 're_namer'
    require 'fileutils'
    config = YAML.load_file(File.join(Rails.root,'/settings/settings.yml'))["config"]
    rename_input_dir = config["renamedir"]
    rename_output_dir = config["destinationdir"]
    @blerm = Renamer.process_dir(rename_input_dir, rename_output_dir)
    render 'home/worker'
  end
  def startDaemon
    require 'xbmc_daemon'
    XbmcDaemon.start
    redirect_to '/'
  end
  def stopDaemon
    require 'xbmc_daemon'
    XbmcDaemon.stop
    redirect_to '/'
  end
  def upload_torrent
    require 'xmission_api'
    xmission = XmissionApi.new(:username => CONFIG["transmission_user"],:password => CONFIG["transmission_password"],:url => CONFIG["transmission_url"])
    xmission.upload_link(params[:torrent], CONFIG["renamedir"])
    redirect_to '/'
  end
  def xbmc_update
    require 'xbmc_api'
    XbmcApi.compose_command("VideoLibrary.Scan")
    redirect_to '/'
  end
  def process_downloads
    xmission = XmissionApi.new(:username => CONFIG["transmission_user"],:password => CONFIG["transmission_password"],:url => CONFIG["transmission_url"])
    XmissionApi.remove_finished_downloads(xmission)
    FileManipulator.process_finished_directory(CONFIG["base_path"], CONFIG["min_videosize"])
    redirect_to '/'
  end
end
