require 'ttdb_helper'
require 'scrubber'
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
    TtdbHelper.get_tvshow_images(self)
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
    updated_ep_ids = []
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
        :ttdb_show_id => episode['seriesid'],
        :airdate => episode['FirstAired'],
        :thumb_url => episode['filename'],
        :thumb_height => episode['thumb_height'],
        :thumb_width => episode['thumb_width']
      )
      updated_ep_ids.push(jdb_episode.id)
    end
    all_ep_ids = episodes.pluck(:id)
    removed_ep_ids = all_ep_ids - updated_ep_ids
    removed_ep_ids.each do |ep|
      episodes.find(ep).destroy
    end
    TtdbHelper.delay(:queue => 'get_images').get_all_episode_thumb(self)
    update_next_episode
    update_latest_episode
  end

  def sync_episodes
    require 'xdb_helper'
    xep = XdbEpisodesHelper.new(xdb_id)
    episodes.each do |ep|
      ep.update_attributes(
        :xdb_id => xep.get_id(ep.season_num, ep.episode_num),
        :filename => xep.get_filename(ep.season_num, ep.episode_num),
        :play_count => xep.get_play_count(ep.season_num, ep.episode_num),
        :last_played => xep.get_last_played(ep.season_num, ep.episode_num),
        :date_added => xep.get_date_added(ep.season_num, ep.episode_num)
      )
    end
  end

  def create_series_folder
    directory_name = File.join(Settings.tvshow_base_path, title)
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
