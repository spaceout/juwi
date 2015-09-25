class AllEpisodesController < ApplicationController

  # GET /episodes
  def index
    @episodes = Episode.where("ttdb_season_number > 0 AND ttdb_episode_airdate < ?", DateTime.now)
  end

  # GET /episodes/missing
  def missing
    @episodes = Episode.missing.sort_by {|u| u.tvshow.title}
    render :index
  end

  def recently_aired
    @episodes = Episode.where("ttdb_season_number > 0 AND ttdb_episode_airdate < ? AND ttdb_episode_airdate > ?", 1.day.ago, 7.days.ago).sort_by(&:ttdb_episode_airdate).reverse
    render :index
  end

  # GET /episodes/1
  def show
    @episode = Episode.find(params[:episode_id])
  end


end
