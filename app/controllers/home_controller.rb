class HomeController < ApplicationController
  def index
    require 'xmission_api'
    require 'file_manipulator'
    require 'xbmc_daemon'
    @tvshows = Tvshow.all.sort_by(&:ttdb_show_title)
    @episodes = Episode.where("ttdb_season_number > 0 AND ttdb_episode_airdate < ?", DateTime.now)
    @completeness = (100 - (@episodes.missing.count.to_f  / @episodes.count.to_f) * 100).round(3)
    @finished_dir = FileManipulator.list_dir(Setting.get_value("finished_path"))
    xmission = XmissionApi.new(
      :username => Setting.get_value("transmission_user"),
      :password => Setting.get_value("transmission_password"),
      :url => Setting.get_value("transmission_url")
    )
    begin
      @transmission_dls = xmission.all
    rescue
      @transmission_dls = nil
    end
  end

  def rename
    require 'xmlsimple'
    require 're_namer'
    require 'fileutils'
    @rename_success = []
    @rename_failure = []
    rename_results = Renamer.process_dir(Setting.get_value("finished_path"), Setting.get_value("tvshow_base_path"))
    rename_results.each do |result|
      if result[:success] != nil
        @rename_success.push(result)
      elsif result[:failure] != nil
        @rename_failure.push(result)
      end
    end
    render 'home/worker'
  end

  def upload_torrent
    require 'xmission_api'
    xmission = XmissionApi.new(
      :username => Setting.get_value("transmission_user"),
      :password => Setting.get_value("transmission_password"),
      :url => Setting.get_value("transmission_url")
    )
    xmission.upload_link(params[:torrent], Setting.get_value("finished_dir"))
    redirect_to(:back)
  end

  def xbmc_update
    require 'xbmc_api'
    XbmcApi.compose_command("VideoLibrary.Scan")
    redirect_to '/'
  end

  def process_downloads
    xmission = XmissionApi.new(
      :username => Setting.get_value("transmission_user"),
      :password => Setting.get_value("transmission_password"),
      :url => Setting.get_value("transmission_url")
    )
    xmission.remove_finished_downloads
    FileManipulator.process_finished_directory(Setting.get_value("finished_path"), Setting.get_value("min_videosize").to_i)
    redirect_to '/'
  end

  def ttdbsearch
    require 'ttdb_helper'
    @search_results = TtdbHelper.search_ttdb(params[:show_title])
  end

end
