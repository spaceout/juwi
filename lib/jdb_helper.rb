class JdbHelper

  def self.update_show(showname)
    require 'mysql'
    require 'sequel'
    require 'ttdb_helper'

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
      File.delete("#{File.join(Rails.root,'/ttdbdata/')}#{show_ttdbid}.zip")
      puts "deleted TTDB zip cache file"
      puts "getting zip and importing show"
      TtdbHelper.get_zip_from_ttdb(show_ttdbid)
      puts "got zip, importing data"
      TtdbHelper.update_ttdb_show_data(show_ttdbid)
      TtdbHelper.update_all_ttdb_episode_data(show_ttdbid)
      JdbHelper.update_jdb_show_data(show_ttdbid)
      TvrHelper.update_tvrage_data(show_ttdbid)
      puts "syncing episode data form XDB to JDB"
      xdbepisodes.where("idShow = #{show_xdbid}").each do |episode|
        JdbHelper.sync_episode_data(episode[:idEpisode])
      end
    end
    xbmcdb.disconnect
    puts "Completed drop and re-import of #{showname}"
  end

  def self.create_new_show(ttdb_id)
    TtdbHelper.update_ttdb_show_data(show_ttdbid)
    TtdbHelper.update_all_ttdb_episode_data(show_ttdbid)
    TvrHelper.update_tvrage_data(show_ttdbid)
  end

  def self.xdbid_to_ttdbid(xdbid)
    xbmcdb = Sequel.connect(Setting.get_value('xbmcdb'))
    xdbtvshows = xbmcdb[:tvshow]
    ttdbid = xdbtvshows.where("idShow = #{xdbid}").first[:c12]
    xbmcdb.disconnect
    return ttdbid
  end

  def self.update_jdb_show_data(ttdb_show_id)
    xbmcdb = Sequel.connect(Setting.get_value('xbmcdb'))
    xdbtvshows = xbmcdb[:tvshow]
    current_xdb_show = xdbtvshows.where("c12 = #{ttdb_show_id}").first
    current_jdb_show = Tvshow.find_by_ttdb_show_id(ttdb_show_id)
    current_jdb_show.update_attributes(
      :xdb_show_location => current_xdb_show[:c16],
      :xdb_show_id => current_xdb_show[:idShow]
    )
    xbmcdb.disconnect
  end

  def self.sync_episode_data(episodeid)
    xbmcdb = Sequel.connect(Setting.get_value('xbmcdb'))
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

