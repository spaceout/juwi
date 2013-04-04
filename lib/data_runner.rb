require 'xmlsimple'
require 'curb'
require 'zip/zipfilesystem'

TTDBCACHE = File.join(Rails.root,'/ttdbdata/')
XBMCDB = 'mysql://xbmc:xbmc@192.168.1.8/MyVideos75'

class DataRunner
  
  def self.get_tvrage_data(showname)
    rage_show = showname.gsub(" ", "%20")
    tvrage_data = get_http_data("http://services.tvrage.com/tools/quickinfo.php?show=#{rage_show}")
    tvrage = Hash[*tvrage_data.gsub!("<pre>","").gsub!("\n","@").split("@")]
    return tvrage
  end

  def self.get_http_data(url)
    body_data = ""
    curl = Curl::Easy.new
    curl.follow_location = true
    curl.url = url
    curl.on_body do |data|
      body_data << data
      data.size
    end
    curl.perform
    return body_data
  end

  def self.download_http_data(url, savelocation)
    curl = Curl::Easy.new
    curl.follow_location = true
    curl.url = url
    File.open(savelocation, 'wb') do|f|
      curl.on_body do |data| 
        f << data
        data.size
      end
      curl.perform
    end
  end

  def self.ttdb_xml_show_data(zipfile, insidefile)
    somezip = Zip::ZipFile.open(zipfile)
    data = XmlSimple.xml_in(somezip.file.read(insidefile))
    return data
  end

  def self.get_zip_from_ttdb(tvdbid)
    download_http_data("http://thetvdb.com/api/8E35AC6C9C5836F0/series/#{tvdbid}/all/en.zip", "/home/jemily/juwi/ttdbdata/#{tvdbid}.zip")
  end

  def self.get_time_from_ttdb
    data = XmlSimple.xml_in(get_http_data("http://thetvdb.com/api/Updates.php?type=none"))
    return data["Time"].first
  end

  def self.get_updates_from_ttdb(lastupdate)
    data = XmlSimple.xml_in(get_http_data("http://thetvdb.com/api/Updates.php?type=all&time=#{lastupdate}"))
    return data
  end

  def self.get_series_from_ttdb(series_id)
    data = XmlSimple.xml_in(get_http_data("http://thetvdb.com/api/8E35AC6C9C5836F0/series/#{series_id}/en.xml"))
  end
  
  def self.get_episode_from_ttdb(episode_id)
    data = XmlSimple.xml_in(get_http_data("http://thetvdb.com/api/8E35AC6C9C5836F0/episodes/#{episode_id}/en.xml"))
  end

  def self.import_new_show_from_xdb(showid)
    xbmcdb = Sequel.connect(XBMCDB)
    xdbtvshows = xbmcdb[:tvshow]
    show = xdbtvshows.where("idShow = #{showid}").first
    #Get ttdb xml data if not in cache
    if File.exist?(TTDBCACHE + show[:c12] +".zip") == false
      puts "downloading " + show[:c00]
      get_zip_from_ttdb(show[:c12])
    end
    ttdbdata = ttdb_xml_show_data("#{TTDBCACHE}#{show[:c12]}.zip", "en.xml")
    #Get TVRage data
    tvragedata = get_tvrage_data(ttdbdata['Series'].first['SeriesName'].first.to_s)
    #Setup all show data
    jdb_ttdb_id = show[:c12]
    xdb_show_location = show[:c16]
    xdb_show_id = show[:idShow]
    jdb_show_title = ttdbdata['Series'].first['SeriesName'].first
    tvr_show_id = tvragedata['Show ID']
    tvr_latest_episode = tvragedata['Latest Episode']
    tvr_latest_episode.force_encoding("utf-8") if tvr_latest_episode != nil
    tvr_next_episode = tvragedata['Next Episode']
    tvr_url = tvragedata['Show URL']
    tvr_started = tvragedata['Started']
    tvr_ended = tvragedata['Ended']
    tvr_status = tvragedata['Status']
    ttdb_imdb_id = ttdbdata['Series'].first['IMDB_ID'].first
    ttdb_overview = ttdbdata['Series'].first['Overview'].first
    ttdb_last_updated = ttdbdata['Series'].first['lastupdated'].first
    ttdb_banner = ttdbdata['Series'].first['banner'].first
    ttdb_fanart = ttdbdata['Series'].first['fanart'].first
    ttdb_poster = ttdbdata['Series'].first['poster'].first
    #Create show db entry
    puts "Creating Show " + jdb_show_title
    puts "Show Status " + tvr_status
    currentShow = Tvshow.create(
      :xdb_show_location => xdb_show_location,
      :xdb_show_id => xdb_show_id,
      :tvr_show_id => tvr_show_id,
      :tvr_latest_episode => tvr_latest_episode,
      :tvr_next_episode => tvr_next_episode,
      :tvr_url => tvr_url,
      :tvr_started => tvr_started,
      :tvr_ended => tvr_ended,
      :tvr_status => tvr_status,
      :ttdb_imdb_id => ttdb_imdb_id,
      :ttdb_last_updated => ttdb_last_updated,
      :ttdb_banner => ttdb_banner,
      :ttdb_fanart => ttdb_fanart,
      :ttdb_poster => ttdb_poster,
      :jdb_ttdb_id => jdb_ttdb_id,
      :ttdb_overview => ttdb_overview,
      :jdb_show_title => jdb_show_title
      )
    ttdbdata['Episode'].each do |episode|
    #Setup episode data
      jdb_episode_title = episode['EpisodeName'].first
      jdb_season_number = episode['SeasonNumber'].first
      jdb_episode_number = episode['EpisodeNumber'].first
      ttdb_episode_id = episode['id'].first
      ttdb_episode_overview = episode['Overview'].first
      ttdb_last_updated = episode['lastupdated'].first
      ttdb_series_id = episode['seriesid'].first
      #Create episode db entry
      puts "  Creating Episode " + jdb_season_number + " " + jdb_episode_number
      currentShow.episodes.create(
        :jdb_episode_title => jdb_episode_title,
        :jdb_season_number => jdb_season_number,
        :jdb_episode_number => jdb_episode_number,
        :ttdb_episode_id => ttdb_episode_id,
        :ttdb_episode_overview => ttdb_episode_overview,
        :ttdb_last_updated => ttdb_last_updated,
        :ttdb_series_id => ttdb_series_id,
        :xdb_show_id => xdb_show_id
        )
    end
    xbmcdb.disconnect
  end

  def self.sync_episode_data(episodeid)
    xbmcdb = Sequel.connect(XBMCDB)
    xdbepisodes = xbmcdb[:episode]
    episode = xdbepisodes.where("idEpisode = #{episodeid}").first
    puts "Syncing #{episode[:c00]}"
    jdbepisode = Episode.where(
      :xdb_show_id => episode[:idShow],
      :jdb_season_number => episode[:c12],
      :jdb_episode_number => episode[:c13]
      ).first
    jdbepisode.update_attributes(
      :xdb_episode_id => episode[:idEpisode],
      :xdb_episode_location => episode[:c18]
      )
    xbmcdb.disconnect
  end
  
  def self.update_ttdb_show_data(ttdbid)
    puts "updating TTDB data for " + Tvshow.where(:jdb_ttdb_id => ttdbid).first.jdb_show_title
    ttdbdata = get_series_from_ttdb(ttdbid)
    show = Tvshow.where(:jdb_ttdb_id => ttdbid).first
    #setup show data
    jdb_show_title = ttdbdata['Series'].first['SeriesName'].first
    ttdb_imdb_id = ttdbdata['Series'].first['IMDB_ID'].first
    ttdb_overview = ttdbdata['Series'].first['Overview'].first
    ttdb_last_updated = ttdbdata['Series'].first['lastupdated'].first
    ttdb_banner = ttdbdata['Series'].first['banner'].first
    ttdb_fanart = ttdbdata['Series'].first['fanart'].first
    ttdb_poster = ttdbdata['Series'].first['poster'].first
    #update show data
    show.update_attributes(
      :ttdb_imdb_id => ttdb_imdb_id,
      :ttdb_last_updated => ttdb_last_updated,
      :ttdb_banner => ttdb_banner,
      :ttdb_fanart => ttdb_fanart,
      :ttdb_poster => ttdb_poster,
      :ttdb_overview => ttdb_overview,
      :jdb_show_title => jdb_show_title
      )
  end

  def self.update_ttdb_episode_data(ttdbid)
    ttdbdata = get_episode_from_ttdb(ttdbid)
    episode = Episode.where(:ttdb_episode_id => ttdbid).first
    print "Updating ttdb data for Episode: "
    print episode.tvshow.jdb_show_title
    print " - "
    print episode.jdb_season_number
    print " "
    puts episode.jdb_season_number
    #setup episode data
    jdb_episode_title = ttdbdata['Episode'].first['EpisodeName'].first
    jdb_season_number = ttdbdata['Episode'].first['SeasonNumber'].first
    jdb_episode_number = ttdbdata['Episode'].first['EpisodeNumber'].first
    ttdb_episode_id = ttdbdata['Episode'].first['id'].first
    ttdb_episode_overview = ttdbdata['Episode'].first['Overview'].first
    ttdb_last_updated = ttdbdata['Episode'].first['lastupdated'].first
    ttdb_series_id = ttdbdata['Episode'].first['seriesid'].first
    #update episode data
    episode.update_attributes(
      :jdb_episode_title => jdb_episode_title,
      :jdb_season_number => jdb_season_number,
      :jdb_episode_number => jdb_episode_number,
      :ttdb_episode_id => ttdb_episode_id,
      :ttdb_episode_overview => ttdb_episode_overview,
      :ttdb_last_updated => ttdb_last_updated,
      :ttdb_series_id => ttdb_series_id
      )
  end

  def self.update_tvrage_data
    Tvshow.all.each do |tvshow|
      next if tvshow.tvr_status == "Canceled/Ended"
      next if tvshow.tvr_status == "Ended"
      next if tvshow.tvr_status == "Canceled"
      puts "Updating TVR for: " + tvshow.jdb_show_title
      tvragedata = get_tvrage_data(tvshow.jdb_show_title)
      #prepare tvr data
      tvr_show_id = tvragedata['Show ID']
      tvr_latest_episode = tvragedata['Latest Episode']
      tvr_latest_episode.force_encoding("utf-8") if tvr_latest_episode != nil
      tvr_next_episode = tvragedata['Next Episode']
      tvr_url = tvragedata['Show URL']
      tvr_started = tvragedata['Started']
      tvr_ended = tvragedata['Ended']
      tvr_status = tvragedata['Status']
      #update tvr data
      tvshow.update_attributes(
        :tvr_show_id => tvr_show_id,
        :tvr_latest_episode => tvr_latest_episode,
        :tvr_next_episode => tvr_next_episode,
        :tvr_url => tvr_url,
        :tvr_started => tvr_started,
        :tvr_ended => tvr_ended,
        :tvr_status => tvr_status
        )
    end
  end
end

