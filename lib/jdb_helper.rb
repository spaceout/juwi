class JdbHelper
  def self.update_show(showname)
    require 'mysql'
    require 'sequel'
    xbmcdb = Sequel.connect(Setting.get_value("xbmcdb"))
    xdbepisodes = xbmcdb[:episode]
    puts "Searching for #{showname} in JDB"
    currentshow = Tvshow.where(:ttdb_show_title => showname)
    if currentshow.empty?
      puts "No Show Found matching #{showname}"
    else
      show_ttdbid = currentshow.first.ttdb_show_id
      show_xdbid = currentshow.first.xdb_show_id
      puts "Found #{showname} in JDB TTDBID = #{show_ttdbid} XDBID = #{show_xdbid}"
      File.delete("#{TTDBCACHE}#{show_ttdbid}.zip")
      puts "deleted TTDB zip cache file"
      puts "getting zip and importing show"
      DataRunner.import_new_show_from_xdb(show_xdbid)
      puts "syncing episode data form XDB to JDB"
      xdbepisodes.where("idShow = #{show_xdbid}").each do |episode|
        DataRunner.sync_episode_data(episode[:idEpisode])
      end
    end
    xbmcdb.disconnect
    puts "Completed drop and re-import of #{showname}"
  end
  def self.sync_show_data(jdb_id)
    #FOR SHOWS
    #xdb_show_location
    #xdb_show_id
    #FOR EPISODES
    #xdb_show_id
  
  end

  def self.sync_episode_data(episodeid)
    xbmcdb = Sequel.connect(CONFIG['xbmcdb'])
    xdbepisodes = xbmcdb[:episode]
    episode = xdbepisodes.where("idEpisode = #{episodeid}").first
    puts "Syncing #{episode[:c00]}"
    jdbepisode = Episode.where(
      :xdb_show_id => episode[:idShow],
      :ttdb_season_number => episode[:c12],
      :ttdb_episode_number => episode[:c13]
    ).first
    unless jdbepisode.nil?
      jdbepisode.update_attributes(
      :xdb_episode_id => episode[:idEpisode],
      :xdb_episode_location => episode[:c18]
    )
    end
    xbmcdb.disconnect
  end

end

