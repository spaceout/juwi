class HomeController < ApplicationController
  def index
    @tvshows = Tvshow.all.sort_by(&:title)
    @episodes = Episode.where("season_num > 0 AND airdate < ?", DateTime.now)
    @completeness = (100 - (@episodes.missing.count.to_f  / @episodes.count.to_f) * 100).round(3)
    @aired_yesterday = Episode.where(:airdate => Date.today.prev_day)
    @airing_today = Episode.where(:airdate => Date.today)
    @airing_tomorrow = Episode.where(:airdate => Date.today.next_day)
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

  def ttdbsearch
    require 'ttdb_helper'
    @search_results = TtdbHelper.search_ttdb(params[:show_title])
  end

end
