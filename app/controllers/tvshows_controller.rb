class TvshowsController < ApplicationController
  # GET /tvshows/forcast
  def forcast
    tvshows_with_date = Tvshow.where("next_episode_date > 0").sort_by(&:next_episode_date)
    airing_status = ["Returning Series", "TBD/On The Bubble", "New Series", "Final Season"]
    tvshows_tba = Tvshow.where(:next_episode_date => nil, :status => airing_status).sort_by(&:title)
    @tvshows = tvshows_with_date + tvshows_tba
    render :index
  end

  def recently_canceled
   # @tvshows_recently_canceled = Tvshow.where("end_date > ? AND end_date < ?", 6.months.ago, Date.today).sort_by(&:end_date).reverse
    @tvshows_recently_canceled = Tvshow.where("status = 'Ended'").where("latest_episode_date > ? AND latest_episode_date < ?", 6.months.ago, Date.today).reverse.select(&:latest_episode_date).sort_by(&:latest_episode_date).reverse
  end

  def index
    @tvshows = Tvshow.all.sort_by(&:title)
  end

  # GET /tvshows/1
  def show
    @tvshow = Tvshow.find(params[:id])
  end

  def edit
    @tvshow = Tvshow.find(params[:id])
  end

  def update
    require 'tvr_helper'
    @tvshow = Tvshow.find(params[:id])
    if @tvshow.update_attributes(params[:tvshow])
      TvrHelper.update_tvrage_data(@tvshow.ttdb_id)
      flash[:notice] = "TV Show Updated"
    else
      flash[:alert] = "Couldn't Update TV Show, fucker"
    end
    redirect_to action: "show"
  end

  def create
    require 'jdb_helper'
    if params[:ttdb_id].nil?
      flash[:notice] = "Could not add TV Show, entry was nil"
      redirect_to '/'
    else
      new_show = Tvshow.new(:ttdb_id => params[:ttdb_id])
      new_show.create_new_show
      flash[:notice] = "TV show added #{params[:ttdb_id]}"
    end
    redirect_to '/'


  end

end
