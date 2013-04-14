class HomeController < ApplicationController
  def index
    @tvshows = Tvshow.all.sort_by(&:ttdb_show_title)
    @episodes = Episode.where("ttdb_season_number > 0 AND ttdb_episode_airdate < ?", DateTime.now)
    @completeness = (100 - (@episodes.missing.count.to_f  / @episodes.count.to_f) * 100).round(2)
  end
end
