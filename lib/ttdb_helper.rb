require 'xmlsimple'
require 'curl_helper'
require 'zip/zipfilesystem'
require 'scrubber'

class TtdbHelper

  def self.update_ttdb_show_data(ttdb_id)
    puts "Updating Show with ttdb id of #{ttdb_id}"
    ttdbdata = TtdbHelper.ttdb_xml_show_data("#{File.join(Rails.root,'/ttdbdata/')}#{ttdb_id}.zip", "en.xml")
    currentShow = Tvshow.find_or_initialize_by_ttdb_show_id(ttdb_id)
    currentShow.update_attributes(
      :ttdb_show_imdb_id => ttdbdata['Series'].first['IMDB_ID'].first,
      :ttdb_show_last_updated => ttdbdata['Series'].first['lastupdated'].first,
      :ttdb_show_banner => ttdbdata['Series'].first['banner'].first,
      :ttdb_show_fanart => ttdbdata['Series'].first['fanart'].first,
      :ttdb_show_poster => ttdbdata['Series'].first['poster'].first,
      :ttdb_show_id => ttdb_id,
      :ttdb_show_overview => ttdbdata['Series'].first['Overview'].first,
      :ttdb_show_title => ttdbdata['Series'].first['SeriesName'].first,
      :ttdb_show_rating => (ttdbdata['Series'].first['Rating'].first unless ttdbdata['Series'].first['Rating'].first.empty?),
      :ttdb_show_rating_count => ttdbdata['Series'].first['RatingCount'].first,
      :ttdb_show_network => ttdbdata['Series'].first['Network'].first,
      :ttdb_show_status => ttdbdata['Series'].first['Status'].first,
      :ttdb_show_runtime => ttdbdata['Series'].first['Runtime'].first,
      :jdb_clean_show_title => Scrubber.clean_show_title(ttdbdata['Series'].first['SeriesName'].first)
    )
  end

  def self.update_ttdb_episode_data(ttdb_show_id, ttdb_episode_id)
    currentShow = Tvshow.find_or_initialize_by_ttdb_show_id(ttdb_show_id)
    episode = TtdbHelper.get_episode_from_ttdb(ttdb_episode_id)['Episode'].first
    currentEpisode = currentShow.episodes.find_or_initialize_by_ttdb_episode_id(ttdb_episode_id)
    currentEpisode.update_attributes(
      :ttdb_episode_title => episode['EpisodeName'].first,
      :ttdb_season_number => episode['SeasonNumber'].first,
      :ttdb_episode_number => episode['EpisodeNumber'].first,
      :ttdb_episode_id => episode['id'].first,
      :ttdb_episode_overview => episode['Overview'].first,
      :ttdb_episode_last_updated => episode['lastupdated'].first,
      :ttdb_show_id => episode['seriesid'].first,
      :ttdb_episode_airdate => episode['FirstAired'].first,
      :ttdb_episode_rating => episode['Rating'].first,
      :ttdb_episode_rating_count => episode['RatingCount'].first,
    )
  end

  def self.update_all_ttdb_episode_data(ttdb_show_id)
    currentShow = Tvshow.find_or_initialize_by_ttdb_show_id(ttdb_show_id)
    ttdbdata = TtdbHelper.ttdb_xml_show_data("#{File.join(Rails.root,'/ttdbdata/')}#{ttdb_show_id}.zip", "en.xml")
    ttdbdata['Episode'].each do |episode|
      currentEpisode = currentShow.episodes.find_or_initialize_by_ttdb_episode_id(episode['id'].first)
      currentEpisode.update_attributes(
        :ttdb_episode_title => episode['EpisodeName'].first,
        :ttdb_season_number => episode['SeasonNumber'].first,
        :ttdb_episode_number => episode['EpisodeNumber'].first,
        :ttdb_episode_id => episode['id'].first,
        :ttdb_episode_overview => episode['Overview'].first,
        :ttdb_episode_last_updated => episode['lastupdated'].first,
        :ttdb_show_id => episode['seriesid'].first,
        :ttdb_episode_airdate => episode['FirstAired'].first,
        :ttdb_episode_rating => episode['Rating'].first,
        :ttdb_episode_rating_count => episode['RatingCount'].first,
      )
    end
  end

  def self.update_all_ttdb_data(show_ttdbid)
    zip_file = "#{File.join(Rails.root,'/ttdbdata/')}#{show_ttdbid}.zip"
    if File.exist?(zip_file)
      puts "deleting file #{zip_file}"
      File.delete(zip_file)
    end
    puts "getting zip and importing show"
    TtdbHelper.get_zip_from_ttdb(show_ttdbid)
    puts "updating ttdb show data for #{show_ttdbid}"
    TtdbHelper.update_ttdb_show_data(show_ttdbid)
    puts "updating ttdb episode data for #{show_ttdbid}"
    TtdbHelper.update_all_ttdb_episode_data(show_ttdbid)
  end

  def self.search_ttdb(search_string)
    data = XmlSimple.xml_in(CurlHelper.get_http_data("http://thetvdb.com/api/GetSeries.php?seriesname=#{search_string}&language=en"), { 'SuppressEmpty' => '' })
    return data
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

  def self.get_time_from_ttdb
    data = nil
    data = XmlSimple.xml_in(CurlHelper.get_http_data("http://thetvdb.com/api/Updates.php?type=none"), { 'SuppressEmpty' => '' })
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
      url = "http://thetvdb.comapi/#{Setting.get_value("ttdb_api_key")}/updates/updates_month.xml"
    end
    data = XmlSimple.xml_in(CurlHelper.get_http_data(url), { 'SuppressEmpty' => '' })
    return data
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
    puts "Something happened downloading image from TTDB"
  end
end
