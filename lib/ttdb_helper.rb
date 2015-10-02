require 'xmlsimple'
require 'curl_helper'
require 'zip/zipfilesystem'
require 'scrubber'

class TtdbHelper

  def initialize(ttdb_id)
    @ttdb_id = ttdb_id
  end

  def get_series_data
    series_data  = XmlSimple.xml_in(CurlHelper.get_http_data("http://thetvdb.com/api/#{Setting.get_value("ttdb_api_key")}/series/#{@ttdb_id}/all/en.xml"), { 'SuppressEmpty' => '', 'ForceArray' => false})
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

  def self.get_all_images(tvshow)
    if tvshow.banner != nil
      CurlHelper.download_http_data("http://thetvdb.com/banners/#{tvshow.banner}", File.join(Rails.root, "/public/images/", "#{tvshow.ttdb_id}_banner.jpg"))
    end
    if tvshow.fanart != nil
      CurlHelper.download_http_data("http://thetvdb.com/banners/#{tvshow.fanart}", File.join(Rails.root, "/public/images/", "#{tvshow.ttdb_id}_fanart.jpg"))
    end
    if tvshow.poster != nil
      CurlHelper.download_http_data("http://thetvdb.com/banners/#{tvshow.poster}", File.join(Rails.root, "/public/images/", "#{tvshow.ttdb_id}_poster.jpg"))
    end
  end
end
=begin
  def self.ttdb_xml_show_data(zipfile, insidefile)
    data = nil
    begin
      somezip = Zip::ZipFile.open(zipfile)
      data = XmlSimple.xml_in(somezip.file.read(insidefile), { 'SuppressEmpty' => '' } )
    rescue
      puts "Something happened getting XML data from TTDB ZIP file"
    end
    return data
  end

  def self.get_zip_from_ttdb(tvdbid)
    CurlHelper.download_http_data("http://thetvdb.com/api/#{Setting.get_value("ttdb_api_key")}/series/#{tvdbid}/all/en.zip", "#{File.join(Rails.root,'/ttdbdata/')}#{tvdbid}.zip")
  end

  def self.delete_ttdb_zip(ttdb_id)
    zip_file = "#{File.join(Rails.root,'/ttdbdata/')}#{ttdb_id}.zip"
    if File.exist?(zip_file)
      #puts "deleting file #{zip_file}"
      File.delete(zip_file)
      return true
    end
    return false
  end

  def self.get_time_from_ttdb
    data = nil
    data = XmlSimple.xml_in(CurlHelper.get_http_data("http://thetvdb.com/api/Updates.php?type=none"), { 'SuppressEmpty' => '' })
    puts "getting time done"
    unless data.nil?
      return data["Time"].first
    end
    return nil
  end

  def self.get_updates_from_ttdb
    current_time = TtdbHelper.get_time_from_ttdb.to_i
    last_update = Setting.get_value("ttdb_last_scrape").to_i
    time_since_last_update = current_time - last_update
    #Get updates from ttdb
    if time_since_last_update < 86400
      puts "Doing Daily Update"
      update_interval = 1
    elsif time_since_last_update < 604800
      puts "Doing Weekly Update"
      update_interval = 2
    elsif time_since_last_update < 18144000
      puts "Doing Monthly Update"
      update_interval = 3
    end
    data = nil
    if update_interval == 1
      url = "http://thetvdb.com/api/#{Setting.get_value("ttdb_api_key")}/updates/updates_day.xml"
    elsif update_interval == 2
      url = "http://thetvdb.com/api/#{Setting.get_value("ttdb_api_key")}/updates/updates_week.xml"
    elsif update_interval == 3
      url = "http://thetvdb.com/api/#{Setting.get_value("ttdb_api_key")}/updates/updates_month.xml"
    end
    data = XmlSimple.xml_in(CurlHelper.get_http_data(url), { 'SuppressEmpty' => '' })
    update_set = []
    unless data["Series"].nil?
      data["Series"].each do |series|
        ttdb_id = series['id'].first
        current_jdb_show = Tvshow.find_by_ttdb_id(ttdb_id)
        next if current_jdb_show == nil
        next if ["Canceled/Ended", "Ended", "Canceled"].include?(current_jdb_show.status)
        update_set.push(ttdb_id)
      end
    end
    return update_set
  end

  def self.get_series_from_ttdb(series_id)
    data = nil
    data = XmlSimple.xml_in(CurlHelper.get_http_data("http://thetvdb.com/api/#{Setting.get_value("ttdb_api_key")}/series/#{series_id}/en.xml"), { 'SuppressEmpty' => '' })
    return data
  end

  def self.get_episode_from_ttdb(episode_id)
    data = nil
    data = XmlSimple.xml_in(CurlHelper.get_http_data("http://thetvdb.com/api/#{Setting.get_value("ttdb_api_key")}/episodes/#{episode_id}/en.xml"), { 'SuppressEmpty' => '' })
    return data
  end

  def self.get_all_data_from_ttdb(series_id)
    data = nil
    data = XmlSimple.xml_in(CurlHelper.get_http_data("http://thetvdb.com/api/#{Setting.get_value("ttdb_api_key")}/series/#{series_id}/all/en.xml"), { 'SuppressEmpty' => '' })
    return data
  end


=end
