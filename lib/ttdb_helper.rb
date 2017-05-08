require 'xmlsimple'
require 'curl_helper'
require 'zip/zipfilesystem'
require 'scrubber'
require 'fileutils'

class TtdbHelper

  def initialize(ttdb_id)
    @ttdb_id = ttdb_id
  end

  def get_series_data
    series_data  = XmlSimple.xml_in(CurlHelper.get_http_data("http://thetvdb.com/api/#{Settings.ttdb_api_key}/series/#{@ttdb_id}/all/en.xml"), { 'SuppressEmpty' => '', 'ForceArray' => false})
  end

  def series_data
    @series_data ||= get_series_data
  end

  def actors
    series_data["Series"]["Actors"]
  end

  def airs_day_of_week
    series_data["Series"]["Airs_DayOfWeek"]
  end

  def airs_time
    series_data["Series"]["Airs_Time"]
  end

  def content_rating
    series_data["Series"]["ContentRating"]
  end

  def first_aired
    series_data["Series"]["FirstAired"]
  end

  def genre
    series_data["Series"]["Genre"]
  end

  def imdb_id
    series_data["Series"]["IMDB_ID"]
  end

  def language
    series_data["Series"]["Language"]
  end

  def network
    series_data["Series"]["Network"]
  end

  def overview
    series_data["Series"]["Overview"]
  end

  def rating
    series_data["Series"]["Rating"]
  end

  def rating_count
    series_data["Series"]["RatingCount"]
  end

  def runtime
    series_data["Series"]["Runtime"]
  end

  def series_name
    series_data["Series"]["SeriesName"]
  end

  def status
    series_data["Series"]["Status"]
  end

  def added
    series_data["Series"]["added"]
  end

  def added_by
    series_data["Series"]["addedBy"]
  end

  def banner
    series_data["Series"]["banner"]
  end

  def fanart
    series_data["Series"]["fanart"]
  end

  def last_updated
    series_data["Series"]["lastupdated"]
  end

  def poster
    series_data["Series"]["poster"]
  end

  def zap2it_id
    series_data["Series"]["zap2it_id"]
  end

  def episodes
    series_data["Episode"]
  end

  def episode(season, episode)

  end

  def self.search_ttdb(search_string)
    data = XmlSimple.xml_in(CurlHelper.get_http_data("http://thetvdb.com/api/GetSeries.php?seriesname=#{URI.encode(search_string)}&language=en"), { 'SuppressEmpty' => '', 'ForceArray' => true})
    result_set = []
    data["Series"].each do |result|
      result_set.push(
        {:series => {
          :ttdb_id => result["seriesid"].first,
          :ttdb_title => result["SeriesName"].first,
          :ttdb_first_aired => result["FirstAired"].try(:first)}
        }
      )
    end
    return result_set
  end

  def self.get_tvshow_images(tvshow)
    tvshow_dir = Rails.root + "public/images/#{tvshow.ttdb_id}/"
    episode_dir = Rails.root + "public/images/#{tvshow.ttdb_id}/episode/"
    FileUtils.mkdir_p(tvshow_dir) unless File.directory?(tvshow_dir)
    FileUtils.mkdir_p(episode_dir) unless File.directory?(episode_dir)
    if tvshow.banner != nil and not File.exist?("#{tvshow_dir}#{tvshow.ttdb_id}_banner.jpg")
      CurlHelper.download_http_data("http://thetvdb.com/banners/#{tvshow.banner}", File.join(tvshow_dir, "#{tvshow.ttdb_id}_banner.jpg"))
    end
    if tvshow.fanart != nil and not File.exist?("#{tvshow_dir}#{tvshow.ttdb_id}_fanart.jpg")
      CurlHelper.download_http_data("http://thetvdb.com/banners/#{tvshow.fanart}", File.join(tvshow_dir, "#{tvshow.ttdb_id}_fanart.jpg"))
    end
    if tvshow.poster != nil and not File.exist?("#{tvshow_dir}#{tvshow.ttdb_id}_poster.jpg")
      CurlHelper.download_http_data("http://thetvdb.com/banners/#{tvshow.poster}", File.join(tvshow_dir, "#{tvshow.ttdb_id}_poster.jpg"))
    end
  end

  def self.get_episode_thumb(episode)
    episode_dir = "public/images/#{episode.tvshow.ttdb_id}/episode/"
    if !episode.thumb_url.empty? and not File.exist?("#{episode_dir}#{episode.ttdb_id}_thumb.jpg")
      CurlHelper.download_http_data("http://thetvdb.com/banners/#{episode.thumb_url}", File.join(Rails.root, episode_dir, "#{episode.ttdb_id}_thumb.jpg"))
    end
  end

  def self.get_all_episode_thumb(tvshow)
    tvshow.episodes.each do |ep|
      get_episode_thumb(ep)
    end
  end
end
