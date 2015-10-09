class AllEpisodesController < ApplicationController

  # GET /episodes
  def index
    @episodes = Episode.where("season_num > 0 AND airdate < ?", DateTime.now)
  end

  # GET /episodes/missing
  def missing
    @episodes = Episode.missing.sort_by {|u| u.tvshow.title}
    render :index
  end

  def recently_aired
    @episodes = Episode.where("season_num > 0 AND airdate < ? AND airdate > ?", 1.day.ago, 7.days.ago).sort_by(&:airdate).reverse
    render :index
  end

  # GET /episodes/1
  def show
    @episode = Episode.find(params[:episode_id])
  end


end
