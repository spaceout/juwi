#WHEN should a show get update:
# - When an episode title is 'TBA'
# - On Demand in the TVshow view (index/show)
# - When the next airing episode is 'TBA'
# - Daily??? - Is this bad for changes in episode scheme(eg splitting season)
# - If a series was cancelled/ended it should never get updated unless on-demand
#Stop storing the zip files, delete 'em when you are done with them
#Ability to update individual episodes (get new names for TBA)



require 'xmlsimple'
require 'curl_helper'
require 'zip/zipfilesystem'
require 'scrubber'

class TtdbHelper

  def self.search_ttdb(search_string)
    data = XmlSimple.xml_in(CurlHelper.get_http_data("http://thetvdb.com/api/GetSeries.php?seriesname=#{URI.encode(search_string)}&language=en"), { 'SuppressEmpty' => '' })
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

  def self.delete_ttdb_zip(ttdb_show_id)
    zip_file = "#{File.join(Rails.root,'/ttdbdata/')}#{ttdb_show_id}.zip"
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
        ttdb_show_id = series['id'].first
        current_jdb_show = Tvshow.find_by_ttdb_show_id(ttdb_show_id)
        next if current_jdb_show == nil
        next if ["Canceled/Ended", "Ended", "Canceled"].include?(current_jdb_show.status)
        update_set.push(ttdb_show_id)
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

  def self.get_all_images(tvshow)
    if tvshow.ttdb_show_banner != nil
      CurlHelper.download_http_data("http://thetvdb.com/banners/#{tvshow.ttdb_show_banner}", File.join(Rails.root, "/public/images/", "#{tvshow.ttdb_show_id}_banner.jpg"))
    end
    if tvshow.ttdb_show_fanart != nil
      CurlHelper.download_http_data("http://thetvdb.com/banners/#{tvshow.ttdb_show_fanart}", File.join(Rails.root, "/public/images/", "#{tvshow.ttdb_show_id}_fanart.jpg"))
    end
    if tvshow.ttdb_show_poster != nil
      CurlHelper.download_http_data("http://thetvdb.com/banners/#{tvshow.ttdb_show_poster}", File.join(Rails.root, "/public/images/", "#{tvshow.ttdb_show_id}_poster.jpg"))
    end
  end
end
