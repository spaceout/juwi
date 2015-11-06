class XdbSeriesHelper
  def initialize(ttdb_id)
    @ttdb_id = ttdb_id
    load_series_data
  end

  def load_series_data
    xbmcdb ||= Sequel.connect(Settings.xbmcdb)
    @xdb_tvshow = xbmcdb[:tvshow_view][:c12 => @ttdb_id]
    xbmcdb.disconnect
  end

  def get_id
    unless @xdb_tvshow.nil?
      series_id = @xdb_tvshow[:idShow]
    else
      return nil
    end
    return series_id
  end

  def get_path
    unless @xdb_tvshow.nil?
      series_path = @xdb_tvshow[:strPath]
    else
      return nil
    end
    return series_path
  end

end

class XdbEpisodesHelper
  def initialize(xdb_show_id)
    @xdb_show_id = xdb_show_id
    load_xdb_episodes
  end

  def load_xdb_episodes
    xbmcdb ||= Sequel.connect(Settings.xbmcdb)
    @xdb_episodes = xbmcdb[:episode_view].where(:idShow => @xdb_show_id).join(:files, :idFile => :idFile).all
    xbmcdb.disconnect
  end

  def get_id(season, episode)
    unless @xdb_episodes.nil?
      episode = @xdb_episodes.find{|ep| ep[:c12] == "#{season}" && ep[:c13] == "#{episode}"}
      unless episode.nil?
        episode_id = episode[:idEpisode]
      else
        return nil
      end
      return episode_id
    end
    return nil
  end

  def get_filename(season, episode)
    unless @xdb_episodes.nil?
      episode = @xdb_episodes.find{|ep| ep[:c12] == "#{season}" && ep[:c13] == "#{episode}"}
      unless episode.nil?
        filename = episode[:strFileName]
      else
        return nil
      end
      return filename
    end
    return nil
  end

  def get_play_count(season, episode)
    unless @xdb_episodes.nil?
      episode = @xdb_episodes.find{|ep| ep[:c12] == "#{season}" && ep[:c13] == "#{episode}"}
      unless episode.nil?
        play_count = episode[:playCount]
      else
        return nil
      end
      return play_count
    end
    return nil
  end

  def get_last_played(season, episode)
    unless @xdb_episodes.nil?
      episode = @xdb_episodes.find{|ep| ep[:c12] == "#{season}" && ep[:c13] == "#{episode}"}
      unless episode.nil?
        last_played = episode[:lastPlayed]
      else
        return nil
      end
      return last_played
    end
    return nil
  end

  def get_date_added(season, episode)
    unless @xdb_episodes.nil?
      episode = @xdb_episodes.find{|ep| ep[:c12] == "#{season}" && ep[:c13] == "#{episode}"}
      unless episode.nil?
        date_added = episode[:dateAdded]
      else
        return nil
      end
      return date_added
    end
    return nil
  end

end

class XdbEpisodeHelper
  def initialize(xdb_episode_id)
    @xdb_episode_id = xdb_episode_id
    load_episode_data
  end

  def load_episode_data
    xbmcdb ||= Sequel.connect(Settings.xbmcdb)
    @xdb_episode = xbmcdb[:episode_view].where(:idEpisode => @xdb_episode_id).first
    xbmcdb.disconnect
  end

  def get_id
    return @xdb_episode_id
  end

  def get_filename
    filename = @xdb_episode[:strFileName]
  end

  def get_season_num
    season_num = @xdb_episode[:c12]
  end

  def get_episode_num
    episode_num = @xdb_episode[:c13]
  end

  def get_show_id
    show_id = @xdb_episode[:idShow]
  end

  def get_play_count
    play_count = @xdb_episode[:playCount]
  end

  def get_last_played
    last_played = @xdb_episode[:lastPlayed]
  end

  def get_date_added
    date_added = @xdb_episode[:dateAdded]
  end

end

class XdbHelper
  def self.get_all_ep_ids
    xbmcdb = Sequel.connect(Settings.xbmcdb)
    xdb_episode_ids = xbmcdb[:episode_view].select_map(:idEpisode)
    xbmcdb.disconnect
    return xdb_episode_ids
  end

  def self.get_all_show_ids
    xbmcdb = Sequel.connect(Settings.xbmcdb)
    xdb_show_ids = xbmcdb[:tvshow_view].select_map(:idShow)
    xbmcdb.disconnect
    return xdb_show_ids
  end

  def self.get_all_show_ttdb_ids
    xbmcdb = Sequel.connect(Settings.xbmcdb)
    xdb_show_ttdb_ids = xbmcdb[:tvshow_view].select_map(:c12).map(&:to_i)
    xbmcdb.disconnect
    return xdb_show_ttdb_ids
  end

  def self.get_multiple_ep_data(ep_ids)
    xbmcdb = Sequel.connect(Settings.xbmcdb)
    ep_data = xbmcdb[:episode_view].where(:idEpisode => ep_ids).all
    xbmcdb.disconnect
    return ep_data
  end

  def self.get_all_play_counts
    xbmcdb = Sequel.connect(Settings.xbmcdb)
    play_counts = xbmcdb[:episode_view].select(:idEpisode, :playCount, :lastPlayed, :dateAdded).where('playCount IS NOT NULL').all
    xbmcdb.disconnect
    return play_counts
  end

end
