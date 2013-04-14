class AllEpisodesController < ApplicationController
def index
    @episodes = Episode.where("ttdb_season_number > 0 AND ttdb_episode_airdate < ?", DateTime.now)
  end

  def missing
    @episodes = Episode.missing
    render :index
  end

  # GET /episodes/1
  def show
    @episode = Episode.find(params[:episode_id])
  end


end
