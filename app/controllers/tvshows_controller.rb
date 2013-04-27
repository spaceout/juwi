class TvshowsController < ApplicationController
  # GET /tvshows/forcast
  def forcast
    tvshows_with_date = Tvshow.where("tvr_next_episode_date > 0").sort_by(&:tvr_next_episode_date)
    airing_status = "Returning Series", "TBD/On The Bubble", "New Series", "Final Season"
    tvshows_tba = Tvshow.where(:tvr_next_episode_date => nil, :tvr_show_status => airing_status).sort_by(&:ttdb_show_title)
    @tvshows = tvshows_with_date + tvshows_tba
    render :index
  end

  def recently_canceled
   # @tvshows_recently_canceled = Tvshow.where("tvr_show_ended > ? AND tvr_show_ended < ?", 6.months.ago, Date.today).sort_by(&:tvr_show_ended).reverse
    @tvshows_recently_canceled = Tvshow.where("tvr_show_status = 'Canceled' OR tvr_show_status = 'Ended' OR tvr_show_status = 'Canceled/Ended'").where("tvr_show_ended > ? AND tvr_show_ended < ?", 6.months.ago, Date.today).reverse.select(&:tvr_latest_episode_date).sort_by(&:tvr_latest_episode_date).reverse + Tvshow.where("tvr_show_status = 'Canceled' OR tvr_show_status = 'Ended' OR tvr_show_status = 'Canceled/Ended'").reject(&:tvr_latest_episode_date) 
  end

  def index
    @tvshows = Tvshow.all.sort_by(&:ttdb_show_title)
  end

  # GET /tvshows/1
  def show
    @tvshow = Tvshow.find(params[:id])
  end

end
