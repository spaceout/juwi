require 'xmlsimple'
require 'curl_helper'
require 'zip/zipfilesystem'

class TtdbHelper

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
    begin
      CurlHelper.download_http_data("http://thetvdb.com/api/#{CONFIG['ttdbapikey']}/series/#{tvdbid}/all/en.zip", "#{TTDBCACHE}#{tvdbid}.zip")
    rescue
      puts "Something happened downloading ZIP from TTDB"
    end
  end

  def self.get_time_from_ttdb
    data = nil
    begin
      data = XmlSimple.xml_in(CurlHelper.get_http_data("http://thetvdb.com/api/Updates.php?type=none"), { 'SuppressEmpty' => '' })
    rescue
      puts "Something happened getting time from TTDB"
    end
    unless data.nil?
      return data["Time"].first
    end
    return nil
  end

  def self.get_updates_from_ttdb(lastupdate,update_interval)
    data = nil
    if update_interval == 1
      url = "http://thetvdb.com/api/#{CONFIG['ttdbapikey']}/updates/updates_day.xml"
    elsif update_interval == 2
      url = "http://thetvdb.com/api/#{CONFIG['ttdbapikey']}/updates/updates_week.xml"
    elsif update_interval == 3
      url = "http://thetvdb.com/api/#{CONFIG['ttdbapikey']}/updates/updates_month.xml"
    end
    begin
      data = XmlSimple.xml_in(CurlHelper.get_http_data(url,2), { 'SuppressEmpty' => '' })
    rescue
      puts "Something happened getting update XML from TTDB"
    end
    return data
  end

  def self.get_series_from_ttdb(series_id)
    data = nil
    begin
      data = XmlSimple.xml_in(CurlHelper.get_http_data("http://thetvdb.com/api/#{CONFIG['ttdbapikey']}/series/#{series_id}/en.xml"), { 'SuppressEmpty' => '' })
    rescue
      puts "Something happened getting series XML from TTDB"
    end
    return data
  end
  
  def self.get_episode_from_ttdb(episode_id)
    data = nil
    begin
      data = XmlSimple.xml_in(CurlHelper.get_http_data("http://thetvdb.com/api/#{CONFIG['ttdbapikey']}/episodes/#{episode_id}/en.xml"), { 'SuppressEmpty' => '' })
    rescue
      puts "Something happened getting episode XML from TTDB"
    end
    return data
  end

  def self.get_all_images(tvshow)
    begin
      if tvshow.ttdb_show_banner != nil
        CurlHelper.download_http_data("http://thetvdb.com/banners/#{tvshow.ttdb_show_banner}", File.join(Rails.root, "/public/images/", "#{tvshow.ttdb_show_id}_banner.jpg"))
      end
      if tvshow.ttdb_show_fanart != nil
        CurlHelper.download_http_data("http://thetvdb.com/banners/#{tvshow.ttdb_show_fanart}", File.join(Rails.root, "/public/images/", "#{tvshow.ttdb_show_id}_fanart.jpg"))
      end
      if tvshow.ttdb_show_poster != nil
        CurlHelper.download_http_data("http://thetvdb.com/banners/#{tvshow.ttdb_show_poster}", File.join(Rails.root, "/public/images/", "#{tvshow.ttdb_show_id}_poster.jpg"))
      end
    rescue
      puts "Something happened downloading image from TTDB"
    end
  end


end
