require 'ttdb_helper'
require 'scrubber'
require 'tvr_helper'
require 'jdb_helper'
require 'xdb_helper'

class Tvshow < ActiveRecord::Base
  has_many :episodes, :dependent => :destroy
  has_many :name_deviations, :dependent => :destroy
  validates :ttdb_id, presence: true, uniqueness: true

  def update_series_data
    seriesdata = TtdbHelper.new(ttdb_id)
    update_attributes(
      :title => seriesdata.series_name,
      :status => seriesdata.status,
      :first_aired => seriesdata.first_aired,
      :imdb_id => seriesdata.imdb_id,
      :overview => seriesdata.overview,
      :ttdb_last_updated => seriesdata.last_updated,
      :banner => seriesdata.banner,
      :fanart => seriesdata.fanart,
      :poster => seriesdata.poster,
      :rating => seriesdata.rating,
      :rating_count => seriesdata.rating_count,
      :network => seriesdata.network,
      :runtime => seriesdata.runtime,
      :clean_title => Scrubber.clean_show_title(seriesdata.series_name)
    )
    update_next_episode
    update_latest_episode
  end

  def sync_series
    xdb_series = XdbSeriesHelper.new(ttdb_id)
    update_attributes(
      :xdb_id => xdb_series.get_id,
      :location => xdb_series.get_path
    )
  end

  def update_episode_data
    show_data = TtdbHelper.new(ttdb_id)
    episode_data = show_data.episodes
    episode_data.each do |episode|
      jdb_episode = episodes.where(
        season_num: episode['SeasonNumber'],
        episode_num: episode['EpisodeNumber']
      ).first_or_initialize
      jdb_episode.update_attributes(
        :title => episode['EpisodeName'],
        :season_num => episode['SeasonNumber'],
        :episode_num => episode['EpisodeNumber'],
        :ttdb_id => episode['id'],
        :overview => episode['Overview'],
        :ttdb_last_updated => episode['lastupdated'],
        :ttdb_id => episode['seriesid'],
        :airdate => episode['FirstAired']
      )
    end
  end

  def sync_episodes
    require 'xdb_helper'
    xep = XdbEpisodeHelper.new(xdb_id)
    episodes.each do |ep|
      ep.update_attributes(
        :xdb_id => xep.get_id(ep.season_num, ep.episode_num),
        :filename => xep.get_filename(ep.season_num, ep.episode_num)
      )
    end
  end

  def sync_episode

  end

  def create_series_folder
    directory_name = File.join(Setting.get_value('tvshow_base_path'), title)
    Dir.mkdir(directory_name) unless File.directory?(directory_name)
  end

  def create_new_show
    update_series_data
    sync_series
    update_episode_data
    sync_episodes
    create_series_folder
  end

  def update_show
    update_series_data
    sync_series
    update_episode_data
    sync_episodes
  end

  def update_latest_episode
    l_episode = episodes.where("airdate <= ?", Date.today).order(:airdate).last
    if l_episode.nil?
      update_attributes(
        :latest_episode => nil,
        :latest_episode_date => nil
      )
    else
      update_attributes(
        :latest_episode => l_episode.id,
        :latest_episode_date => l_episode.airdate
      )
    end
  end

  def update_next_episode
    if status == "Ended"
      update_attributes(
        :next_episode => nil,
        :next_episode_date => nil
      )
      return
    end
    n_episode = episodes.where("airdate >= ?", Date.today).order(:airdate).first
    if n_episode.nil?
      update_attributes(
        :next_episode => nil,
        :next_episode_date => nil
      )
    else
      update_attributes(
        :next_episode => n_episode.id,
        :next_episode_date => n_episode.airdate
      )
    end
  end
end

=begin

  def self.create_and_sync_new_show(ttdb_id)
    puts "getting zip"
    TtdbHelper.get_zip_from_ttdb(ttdb_id)
    puts "updating ttdb show data for"
    Tvshow.update_ttdb_show_data(ttdb_id)
    puts "updating ttdb episode data"
    Tvshow.update_all_ttdb_episode_data(ttdb_id)
    #puts "updating tvr information"
    #Tvshow.update_tvrage_data(ttdb_id)
    puts "synching xdb show info"
    Tvshow.update_xdb_show_data(ttdb_id)
    puts "synching xdb episode data"
    Tvshow.update_all_xdb_episode_data(ttdb_id)
  end

  def self.update_ttdb_show_data(ttdb_id)
    ttdbdata = TtdbHelper.ttdb_xml_show_data("#{File.join(Rails.root,'/ttdbdata/')}#{ttdb_id}.zip", "en.xml")
    currentShow = Tvshow.find_or_initialize_by_ttdb_id(ttdb_id)
    currentShow.update_attributes(
      :last_updated => ttdbdata['Series'].first['lastupdated'].first,
      :banner => ttdbdata['Series'].first['banner'].first,
      :fanart => ttdbdata['Series'].first['fanart'].first,
      :poster => ttdbdata['Series'].first['poster'].first,
      :ttdb_id => ttdb_id,
      :overview => ttdbdata['Series'].first['Overview'].first,
      :title => ttdbdata['Series'].first['SeriesName'].first,
      :network => ttdbdata['Series'].first['Network'].first,
      :status => ttdbdata['Series'].first['Status'].first,
      :runtime => ttdbdata['Series'].first['Runtime'].first,
      :clean_title => Scrubber.clean_show_title(ttdbdata['Series'].first['SeriesName'].first)
    )
  end

  def self.update_ttdb_episode_data(ttdb_id)
    episode = TtdbHelper.get_episode_from_ttdb(ttdb_id)['Episode'].first
    ttdb_id = episode['seriesid'].first
    current_show = Tvshow.find_or_initialize_by_ttdb_id(ttdb_id)
    #current_episode = currentShow.episodes.find_or_initialize_by_ttdb_id(ttdb_id)
    current_episode = current_show.episodes.where(
      season_num: episode['SeasonNumber'].first,
      episode_num: episode['EpisodeNumber'].first
    ).first_or_initialize
    current_episode.update_attributes(
      :title => episode['EpisodeName'].first,
      :season_num => episode['SeasonNumber'].first,
      :episode_num => episode['EpisodeNumber'].first,
      :ttdb_id => episode['id'].first,
      :overview => episode['Overview'].first,
      :ttdb_last_updated => episode['lastupdated'].first,
      :ttdb_id => episode['seriesid'].first,
      :airdate => episode['FirstAired'].first,
    )
  end

  def self.update_all_ttdb_episode_data(ttdb_id)
    current_show = Tvshow.find_or_initialize_by_ttdb_id(ttdb_id)
    ttdbdata = TtdbHelper.ttdb_xml_show_data("#{File.join(Rails.root,'/ttdbdata/')}#{ttdb_id}.zip", "en.xml")
    ttdbdata['Episode'].each do |episode|
      #currentEpisode = currentShow.episodes.find_or_initialize_by_ttdb_id(episode['id'].first)
      current_episode = current_show.episodes.where(
        season_num: episode['SeasonNumber'].first,
        episode_num: episode['EpisodeNumber'].first
      ).first_or_initialize
      current_episode.update_attributes(
        :title => episode['EpisodeName'].first,
        :season_num => episode['SeasonNumber'].first,
        :episode_num => episode['EpisodeNumber'].first,
        :ttdb_id => episode['id'].first,
        :overview => episode['Overview'].first,
        :ttdb_last_updated => episode['lastupdated'].first,
        :ttdb_id => episode['seriesid'].first,
        :airdate => episode['FirstAired'].first,
      )
    end
  end

  def self.update_all_ttdb_data(ttdb_id)
    #puts "deleting zip"
    TtdbHelper.delete_ttdb_zip(ttdb_id)
    #puts "getting new zip"
    TtdbHelper.get_zip_from_ttdb(ttdb_id)
    #puts "deleting all episodes"
    Tvshow.find_by_ttdb_id(ttdb_id).episodes.destroy
    #puts "updating ttdb show data for #{ttdb_id}"
    Tvshow.update_ttdb_show_data(ttdb_id)
    #puts "updating ttdb episode data for #{ttdb_id}"
    Tvshow.update_all_ttdb_episode_data(ttdb_id)
    #puts "resynching with XDB"
    Tvshow.update_xdb_show_data(ttdb_id)
    Tvshow.update_all_xdb_episode_data(ttdb_id)
    tvshow = Tvshow.where(:ttdb_id => ttdb_id).first
    tvshow.update_next_episode
    tvshow.update_latest_episode
  end


  ###########
  #XDB Stuff#
  ###########

  def self.update_xdb_show_data(ttdb_id)
    xbmcdb = Sequel.connect(Setting.get_value('xbmcdb'))
    xdbtvshows = xbmcdb[:tvshow]
    current_xdb_show = xdbtvshows.where(:c12 => ttdb_id).first
    current_jdb_show = Tvshow.find_by_ttdb_id(ttdb_id)
    current_jdb_show.update_attributes(
      :location => current_xdb_show[:c16],
      :xdb_id => current_xdb_show[:idShow]
    )
    current_jdb_show.episodes.each do |episode|
      episode.update_attributes(
        :xdb_id => current_xdb_show[:idShow]
      )
    end
    xbmcdb.disconnect
  end

  def self.update_xdb_episode_data(xdb_id)
    xbmcdb = Sequel.connect(Setting.get_value('xbmcdb'))
    xdbepisodes = xbmcdb[:episode]
    xdb_ep = xdbepisodes.where(:idEpisode => xdb_id).first
    puts "Syncing #{xdb_ep[:c00]}"
    jdbepisode = Episode.where(xdb_id: xdb_ep[:idShow], season_num: xdb_ep[:c12], episode_num: xdb_ep[:c13]).first
    if jdbepisode != nil
      jdbepisode.update_attributes(
      xdb_id: xdb_ep[:idEpisode],
      filename: xdb_ep[:c18]
    )
    end
    xbmcdb.disconnect
  end

  def self.update_all_xdb_episode_data(ttdb_id)
    xdb_id = JdbHelper.ttdbid_to_xdbid(ttdb_id)
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

  def self.remove_xdb_episode_data(ttdb_id)
    episode = Episode.find_by_ttdb_id(ttdb_id)
    episode.update_attributes(
      :xdb_id => nil,
      :filename => nil
    )
  end

###########
#TVR Stuff#
###########

def self.update_tvrage_data(ttdb_id)
  current_show = Tvshow.find_by_ttdb_id(ttdb_id)
  title = current_show.clean_title
  #puts "Updating TVR for: #{title}"
  tvragedata = TvrHelper.get_tvrage_data(title)
  return if tvragedata == nil;
  tvr_latest_episode = tvragedata['Latest Episode']
  if tvr_latest_episode != nil
    tvr_latest_episode.force_encoding("utf-8")
    latest_season_number = tvr_latest_episode.split("^").first.split("x")[0]
    latest_episode_number = tvr_latest_episode.split("^").first.split("x")[1]
    latest_episode_title = tvr_latest_episode.split("^")[1]
    latest_episode_date = tvr_latest_episode.split("^")[2]
  end
  tvr_next_episode = tvragedata['Next Episode']
  if tvr_next_episode != nil
    tvr_next_episode.force_encoding("utf-8")
    next_season_number = tvr_next_episode.split("^").first.split("x")[0]
    next_episode_number = tvr_next_episode.split("^").first.split("x")[1]
    next_episode_title = tvr_next_episode.split("^")[1]
    next_episode_date = tvr_next_episode.split("^")[2]
  else
    next_season_number = nil
    next_episode_number = nil
    next_episode_title = nil
    next_episode_date = nil
  end
  current_show.update_attributes(
    :tvr_id => tvragedata['Show ID'],
    :latest_season_number => latest_season_number,
    :latest_episode_number => latest_episode_number,
    :latest_episode_title => latest_episode_title,
    :latest_episode_date => latest_episode_date,
    :next_season_number => next_season_number,
    :next_episode_number => next_episode_number,
    :next_episode_title => next_episode_title,
    :next_episode_date => next_episode_date,
    :tvr_url => tvragedata['Show URL'],
    :first_aired => tvragedata['Started'],
    :end_date => tvragedata['Ended'],
    :status => tvragedata['Status']
    )
end
=end
