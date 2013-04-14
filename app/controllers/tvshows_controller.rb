class TvshowsController < ApplicationController
  # GET /tvshows/forcast
  def forcast
    @tvshows = Tvshow.where("tvr_next_episode_date > 0").sort_by(&:tvr_next_episode_date)
    render :index
  end

  def index
    @tvshows = Tvshow.all.sort_by(&:ttdb_show_title)
  end

  def missing
    render :index
  end

  # GET /tvshows/1
  def show
    @tvshow = Tvshow.find(params[:id])
  end

  # GET /tvshows/1/edit
  def edit
    @tvshow = Tvshow.find(params[:id])
  end
end
