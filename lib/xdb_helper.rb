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
    @xbmcdb.disconnect
    return series_id
  end

  def get_path
    series_path = xdb_tvshow[:strPath]
    @xbmcdb.disconnect
    return series_path
  end

end

class XdbEpisodeHelper
  def initialize(xdb_show_id)
    @xdb_show_id = xdb_show_id
    load_xdb_episodes
  end

  def load_xdb_episodes
    xbmcdb ||= Sequel.connect(Setting.get_value('xbmcdb'))
    @xdb_episodes = xbmcdb[:episodeview].where(:idShow => @xdb_show_id).all
    xbmcdb.disconnect
  end

  def get_id(season_num, episode_num)
    unless @xdb_episodes.nil?
      episode_id = @xdb_episodes.find{|ep| ep[:c12] = season_num; ep[:c13] = episode_num}[:idEpisode]
      return episode_id
    end
    return nil
  end

  def get_filename(season_num, episode_num)
    unless @xdb_episodes.nil?
      filename = @xdb_episodes.find{|ep| ep[:c12] = season_num; ep[:c13] = episode_num}[:strFileName]
      return filename
    end
    return nil
  end
end
