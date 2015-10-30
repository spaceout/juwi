class EpisodesController < ApplicationController
  # GET /tvshow/:tvshow_id/episodes
  def index
    @tvshow = Tvshow.find(params[:tvshow_id])
    @episodes = @tvshow.episodes.where("season_num > 0 AND airdate < ?", DateTime.now)
  end

  def show
    @episode = Episode.find(params[:id])
  end

  def show2
    @episode = Episode.find(params[:episode_id])
    render :show
  end

  def edit
    @episode = Episode.find(params[:id])
  end

  def all
    @episodes = Episode.where("season_num > 0 AND airdate < ?", DateTime.now)
    render :index2
  end

  def missing
    @episodes = Episode.missing.sort_by {|u| u.tvshow.title}
    render :index2
  end

  def recently_aired
    @episodes = Episode.where("season_num > 0 AND airdate < ? AND airdate > ?", 1.day.ago, 7.days.ago).sort_by(&:airdate).reverse
    render :index2
  end

end
