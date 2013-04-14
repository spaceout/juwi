class EpisodesController < ApplicationController
  # GET /tvshow/:tvshow_id/episodes
  def index
    @tvshow = Tvshow.find(params[:tvshow_id])
    @episodes = @tvshow.episodes.where("ttdb_season_number > 0 AND ttdb_episode_airdate < ?", DateTime.now)
  end

  def missing
    @tvshow = Tvshow.find(1)
    @episodes = Episode.missing
    render :index
  end

  # GET /episodes/1
  def show
    @episode = Episode.find(params[:id])
  end

  # GET /episodes/1/edit
  def edit
    @episode = Episode.find(params[:id])
  end
end
