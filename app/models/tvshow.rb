require 'ttdb_helper'
require 'scrubber'
require 'tvr_helper'
require 'jdb_helper'

class Tvshow < ActiveRecord::Base
  has_many :episodes, :dependent => :destroy
  has_many :name_deviations, :dependent => :destroy

  def self.create_new_show(ttdb_show_id)
    puts "getting zip"
    TtdbHelper.get_zip_from_ttdb(ttdb_show_id)
    puts "updating ttdb show data for"
    Tvshow.update_ttdb_show_data(ttdb_show_id)
    puts "updating ttdb episode data"
    Tvshow.update_all_ttdb_episode_data(ttdb_show_id)
    puts "updating tvr information"
    Tvshow.update_tvrage_data(ttdb_show_id)
  end

  def self.create_and_sync_new_show(ttdb_show_id)
    puts "getting zip"
    TtdbHelper.get_zip_from_ttdb(ttdb_show_id)
    puts "updating ttdb show data for"
    Tvshow.update_ttdb_show_data(ttdb_show_id)
    puts "updating ttdb episode data"
    Tvshow.update_all_ttdb_episode_data(ttdb_show_id)
    puts "updating tvr information"
    Tvshow.update_tvrage_data(ttdb_show_id)
    puts "synching xdb show info"
    Tvshow.update_xdb_show_data(ttdb_show_id)
    puts "synching xdb episode data"
    Tvshow.update_all_xdb_episode_data(ttdb_show_id)
  end


  ############
  #TTDB Stuff#
  ############

  def self.update_ttdb_show_data(ttdb_show_id)
    ttdbdata = TtdbHelper.ttdb_xml_show_data("#{File.join(Rails.root,'/ttdbdata/')}#{ttdb_show_id}.zip", "en.xml")
    currentShow = Tvshow.find_or_initialize_by_ttdb_show_id(ttdb_show_id)
    currentShow.update_attributes(
      :ttdb_show_last_updated => ttdbdata['Series'].first['lastupdated'].first,
      :ttdb_show_banner => ttdbdata['Series'].first['banner'].first,
      :ttdb_show_fanart => ttdbdata['Series'].first['fanart'].first,
      :ttdb_show_poster => ttdbdata['Series'].first['poster'].first,
      :ttdb_show_id => ttdb_show_id,
      :ttdb_show_overview => ttdbdata['Series'].first['Overview'].first,
      :ttdb_show_title => ttdbdata['Series'].first['SeriesName'].first,
      :ttdb_show_network => ttdbdata['Series'].first['Network'].first,
      :ttdb_show_status => ttdbdata['Series'].first['Status'].first,
      :ttdb_show_runtime => ttdbdata['Series'].first['Runtime'].first,
      :jdb_clean_show_title => Scrubber.clean_show_title(ttdbdata['Series'].first['SeriesName'].first)
    )
    if currentShow.tvr_search_name == nil
      currentShow.update_attributes(
        :tvr_search_name => currentShow.ttdb_show_title
      )
    end
  end

  def self.update_ttdb_episode_data(ttdb_episode_id)
    episode = TtdbHelper.get_episode_from_ttdb(ttdb_episode_id)['Episode'].first
    ttdb_show_id = episode['seriesid'].first
    current_show = Tvshow.find_or_initialize_by_ttdb_show_id(ttdb_show_id)
    #current_episode = currentShow.episodes.find_or_initialize_by_ttdb_episode_id(ttdb_episode_id)
    current_episode = current_show.episodes.where(
      ttdb_season_number: episode['SeasonNumber'].first,
      ttdb_episode_number: episode['EpisodeNumber'].first
    ).first_or_initialize
    current_episode.update_attributes(
      :ttdb_episode_title => episode['EpisodeName'].first,
      :ttdb_season_number => episode['SeasonNumber'].first,
      :ttdb_episode_number => episode['EpisodeNumber'].first,
      :ttdb_episode_id => episode['id'].first,
      :ttdb_episode_overview => episode['Overview'].first,
      :ttdb_episode_last_updated => episode['lastupdated'].first,
      :ttdb_show_id => episode['seriesid'].first,
      :ttdb_episode_airdate => episode['FirstAired'].first,
    )
  end

  def self.update_all_ttdb_episode_data(ttdb_show_id)
    current_show = Tvshow.find_or_initialize_by_ttdb_show_id(ttdb_show_id)
    ttdbdata = TtdbHelper.ttdb_xml_show_data("#{File.join(Rails.root,'/ttdbdata/')}#{ttdb_show_id}.zip", "en.xml")
    ttdbdata['Episode'].each do |episode|
      #currentEpisode = currentShow.episodes.find_or_initialize_by_ttdb_episode_id(episode['id'].first)
      current_episode = current_show.episodes.where(
        ttdb_season_number: episode['SeasonNumber'].first,
        ttdb_episode_number: episode['EpisodeNumber'].first
      ).first_or_initialize
      current_episode.update_attributes(
        :ttdb_episode_title => episode['EpisodeName'].first,
        :ttdb_season_number => episode['SeasonNumber'].first,
        :ttdb_episode_number => episode['EpisodeNumber'].first,
        :ttdb_episode_id => episode['id'].first,
        :ttdb_episode_overview => episode['Overview'].first,
        :ttdb_episode_last_updated => episode['lastupdated'].first,
        :ttdb_show_id => episode['seriesid'].first,
        :ttdb_episode_airdate => episode['FirstAired'].first,
      )
    end
  end

  def self.update_all_ttdb_data(ttdb_show_id)
    #puts "deleting zip"
    TtdbHelper.delete_ttdb_zip(ttdb_show_id)
    #puts "getting new zip"
    TtdbHelper.get_zip_from_ttdb(ttdb_show_id)
    #puts "deleting all episodes"
    Tvshow.find_by_ttdb_show_id(ttdb_show_id).episodes.destroy
    #puts "updating ttdb show data for #{ttdb_show_id}"
    Tvshow.update_ttdb_show_data(ttdb_show_id)
    #puts "updating ttdb episode data for #{ttdb_show_id}"
    Tvshow.update_all_ttdb_episode_data(ttdb_show_id)
    #puts "resynching with XDB"
    Tvshow.update_xdb_show_data(ttdb_show_id)
    Tvshow.update_all_xdb_episode_data(ttdb_show_id)
  end

  ###########
  #TVR Stuff#
  ###########

  def self.update_tvrage_data(ttdb_show_id)
    current_show = Tvshow.find_by_ttdb_show_id(ttdb_show_id)
    title = current_show.tvr_search_name
    #puts "Updating TVR for: #{title}"
    tvragedata = TvrHelper.get_tvrage_data(title)
    tvr_latest_episode = tvragedata['Latest Episode']
    if tvr_latest_episode != nil
      tvr_latest_episode.force_encoding("utf-8")
      tvr_latest_season_number = tvr_latest_episode.split("^").first.split("x")[0]
      tvr_latest_episode_number = tvr_latest_episode.split("^").first.split("x")[1]
      tvr_latest_episode_title = tvr_latest_episode.split("^")[1]
      tvr_latest_episode_date = tvr_latest_episode.split("^")[2]
    end
    tvr_next_episode = tvragedata['Next Episode']
    if tvr_next_episode != nil
      tvr_next_episode.force_encoding("utf-8")
      tvr_next_season_number = tvr_next_episode.split("^").first.split("x")[0]
      tvr_next_episode_number = tvr_next_episode.split("^").first.split("x")[1]
      tvr_next_episode_title = tvr_next_episode.split("^")[1]
      tvr_next_episode_date = tvr_next_episode.split("^")[2]
    end
    current_show.update_attributes(
      :tvr_show_id => tvragedata['Show ID'],
      :tvr_latest_season_number => tvr_latest_season_number,
      :tvr_latest_episode_number => tvr_latest_episode_number,
      :tvr_latest_episode_title => tvr_latest_episode_title,
      :tvr_latest_episode_date => tvr_latest_episode_date,
      :tvr_next_season_number => tvr_next_season_number,
      :tvr_next_episode_number => tvr_next_episode_number,
      :tvr_next_episode_title => tvr_next_episode_title,
      :tvr_next_episode_date => tvr_next_episode_date,
      :tvr_show_url => tvragedata['Show URL'],
      :tvr_show_started => tvragedata['Started'],
      :tvr_show_ended => tvragedata['Ended'],
      :tvr_show_status => tvragedata['Status']
      )
  end

  ###########
  #XDB Stuff#
  ###########

  def self.update_xdb_show_data(ttdb_show_id)
    xbmcdb = Sequel.connect(Setting.get_value('xbmcdb'))
    xdbtvshows = xbmcdb[:tvshow]
    current_xdb_show = xdbtvshows.where(:c12 => ttdb_show_id).first
    current_jdb_show = Tvshow.find_by_ttdb_show_id(ttdb_show_id)
    current_jdb_show.update_attributes(
      :xdb_show_location => current_xdb_show[:c16],
      :xdb_show_id => current_xdb_show[:idShow]
    )
    current_jdb_show.episodes.each do |episode|
      episode.update_attributes(
        :xdb_show_id => current_xdb_show[:idShow]
      )
    end
    xbmcdb.disconnect
  end

  def self.update_xdb_episode_data(xdb_episode_id)
    xbmcdb = Sequel.connect(Setting.get_value('xbmcdb'))
    xdbepisodes = xbmcdb[:episode]
    xdb_ep = xdbepisodes.where(:idEpisode => xdb_episode_id).first
    puts "Syncing #{xdb_ep[:c00]}"
    jdbepisode = Episode.where(xdb_show_id: xdb_ep[:idShow], ttdb_season_number: xdb_ep[:c12], ttdb_episode_number: xdb_ep[:c13]).first
    if jdbepisode != nil
      jdbepisode.update_attributes(
      xdb_episode_id: xdb_ep[:idEpisode],
      xdb_episode_location: xdb_ep[:c18]
    )
    end
    xbmcdb.disconnect
  end

  def self.update_all_xdb_episode_data(ttdb_show_id)
    xdb_id = JdbHelper.ttdbid_to_xdbid(ttdb_show_id)
    xbmcdb = Sequel.connect(Setting.get_value('xbmcdb'))
    xdbepisodes = xbmcdb[:episode]
    eps = xdbepisodes.where("idShow = #{xdb_id}")
    unless eps == nil
      eps.each do |ep|
        update_xdb_episode_data(ep[:idEpisode])
      end
    end
    xbmcdb.disconnect
  end

  def self.remove_xdb_episode_data(ttdb_episode_id)
    episode = Episode.find_by_ttdb_episode_id(ttdb_episode_id)
    episode.update_attributes(
      :xdb_episode_id => nil,
      :xdb_episode_location => nil
    )
  end

end
