class XdbSeriesHelper
  def initialize(ttdb_id)
    @ttdb_id = ttdb_id
  end

  def xbmcdb
    @xbmcdb ||= Sequel.connect(Setting.get_value('xbmcdb'))
  end

  def xdb_tvshow
    @xdb_tvshow ||= xbmcdb[:tvshowview][:c12 => @ttdb_id]
  end

  def get_id
    series_id = xdb_tvshow[:idShow]
  end

  def get_location
    series_location = xdb_tvshow[:strPath]
  end

end

class XdbEpisodeHelper
  def initialize(show_id, season_num, episode_num)
    @show_id = show_id
    @season_num = season_num
    @episode_num = episode_num
  end

  def xbmcdb
    @xbmcdb ||= Sequel.connect(Setting.get_value('xbmcdb'))
  end

  def xdb_episode
    @xdb_episode ||= xbmcdb[:episodeview][:idShow => @show_id, :c12 => @season_num, :c13 => @episode_num]
  end

  def get_id
    episode_id = xdb_episode[:idEpisode]
  end

  def get_location
    episode_location = xdb_episode[:strFileName]
  end
end
