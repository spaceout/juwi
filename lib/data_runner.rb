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
    puts "Downloading: #{url}"
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
      download_http_data("http://thetvdb.com/api/8E35AC6C9C5836F0/series/#{tvdbid}/all/en.zip", "#{TTDBCACHE}#{tvdbid}.zip")
    rescue
      puts "Something happened downloading ZIP from TTDB"
    end
  end

  def self.get_time_from_ttdb
    data = nil
    begin
      data = XmlSimple.xml_in(get_http_data("http://thetvdb.com/api/Updates.php?type=none"), { 'SuppressEmpty' => '' })
    rescue
      puts "Something happened getting time from TTDB"
    end
    unless data.nil?
      return data["Time"].first
    end
    return nil
  end

  def self.get_updates_from_ttdb(lastupdate)
    data = nil
    begin
      data = XmlSimple.xml_in(get_http_data("http://thetvdb.com/api/Updates.php?type=all&time=#{lastupdate}"), { 'SuppressEmpty' => '' })
    rescue
      puts "Something happened getting update XML from TTDB"
    end
    return data
  end

  def self.get_series_from_ttdb(series_id)
    data = nil
    begin
      data = XmlSimple.xml_in(get_http_data("http://thetvdb.com/api/8E35AC6C9C5836F0/series/#{series_id}/en.xml"), { 'SuppressEmpty' => '' })
    rescue
      puts "Something happened getting series XML from TTDB"
    end
    return data
  end
  
  def self.get_episode_from_ttdb(episode_id)
    data = nil
    begin
      data = XmlSimple.xml_in(get_http_data("http://thetvdb.com/api/8E35AC6C9C5836F0/episodes/#{episode_id}/en.xml"), { 'SuppressEmpty' => '' })
    rescue
      puts "Something happened getting episode XML from TTDB"
    end
    return data
  end
#fix null values for:
  #Show:
    #ttdb_show_imdb_id
    #banner
    #fanart
    #poster
    #show rating
    #show overview
  #episode
    #episode overview
    #episode rating
    #episode airdate
    #episode title
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
    ttdb_show_id = show[:c12]
    xdb_show_location = show[:c16]
    xdb_show_id = show[:idShow]
    ttdb_show_title = ttdbdata['Series'].first['SeriesName'].first
    tvr_show_id = tvragedata['Show ID']
    #Processing of tvrage next/latest episode
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
    tvr_show_url = tvragedata['Show URL']
    tvr_show_started = tvragedata['Started']
    tvr_show_ended = tvragedata['Ended']
    tvr_show_status = tvragedata['Status']
    ttdb_show_imdb_id = ttdbdata['Series'].first['IMDB_ID'].first
    ttdb_show_overview = ttdbdata['Series'].first['Overview'].first
    ttdb_show_last_updated = ttdbdata['Series'].first['lastupdated'].first
    ttdb_show_banner = ttdbdata['Series'].first['banner'].first
    ttdb_show_fanart = ttdbdata['Series'].first['fanart'].first
    ttdb_show_poster = ttdbdata['Series'].first['poster'].first
    ttdb_show_rating = nil
    ttdb_show_rating = ttdbdata['Series'].first['Rating'].first unless ttdbdata['Series'].first['Rating'].first.empty?
    ttdb_show_rating_count = ttdbdata['Series'].first['RatingCount'].first
    ttdb_show_network = ttdbdata['Series'].first['Network'].first
    ttdb_show_status = ttdbdata['Series'].first['Status'].first
    ttdb_show_runtime = ttdbdata['Series'].first['Runtime'].first
    #Create show db entry
    puts "Creating Show " + ttdb_show_title
    currentShow = Tvshow.create(
      :xdb_show_location => xdb_show_location,
      :xdb_show_id => xdb_show_id,
      :tvr_show_id => tvr_show_id,
      :tvr_latest_season_number => tvr_latest_season_number,
      :tvr_latest_episode_number => tvr_latest_episode_number,
      :tvr_latest_episode_title => tvr_latest_episode_title,
      :tvr_latest_episode_date => tvr_latest_episode_date,
      :tvr_next_season_number => tvr_next_season_number,
      :tvr_next_episode_number => tvr_next_episode_number,
      :tvr_next_episode_title => tvr_next_episode_title,
      :tvr_next_episode_date => tvr_next_episode_date,
      :tvr_show_url => tvr_show_url,
      :tvr_show_started => tvr_show_started,
      :tvr_show_ended => tvr_show_ended,
      :tvr_show_status => tvr_show_status,
      :ttdb_show_imdb_id => ttdb_show_imdb_id,
      :ttdb_show_last_updated => ttdb_show_last_updated,
      :ttdb_show_banner => ttdb_show_banner,
      :ttdb_show_fanart => ttdb_show_fanart,
      :ttdb_show_poster => ttdb_show_poster,
      :ttdb_show_id => ttdb_show_id,
      :ttdb_show_overview => ttdb_show_overview,
      :ttdb_show_title => ttdb_show_title,
      :ttdb_show_rating => ttdb_show_rating,
      :ttdb_show_rating_count => ttdb_show_rating_count,
      :ttdb_show_network => ttdb_show_network,
      :ttdb_show_status => ttdb_show_status,
      :ttdb_show_runtime => ttdb_show_runtime
      )
    ttdbdata['Episode'].each do |episode|
    #Setup episode data
      ttdb_episode_title = episode['EpisodeName'].first
      ttdb_season_number = episode['SeasonNumber'].first
      ttdb_episode_number = episode['EpisodeNumber'].first
      ttdb_episode_id = episode['id'].first
      ttdb_episode_overview = episode['Overview'].first
      ttdb_episode_last_updated = episode['lastupdated'].first
      ttdb_show_id = episode['seriesid'].first
      ttdb_episode_airdate = episode['FirstAired'].first
      ttdb_episode_rating = episode['Rating'].first
      ttdb_episode_rating_count = episode['RatingCount'].first
      #Create episode db entry
      puts "  Creating Episode " + ttdb_season_number + " " + ttdb_episode_number
      currentShow.episodes.create(
        :ttdb_episode_title => ttdb_episode_title,
        :ttdb_season_number => ttdb_season_number,
        :ttdb_episode_number => ttdb_episode_number,
        :ttdb_episode_id => ttdb_episode_id,
        :ttdb_episode_overview => ttdb_episode_overview,
        :ttdb_episode_last_updated => ttdb_episode_last_updated,
        :ttdb_show_id => ttdb_show_id,
        :ttdb_episode_airdate => ttdb_episode_airdate,
        :ttdb_episode_rating => ttdb_episode_rating,
        :ttdb_episode_rating_count => ttdb_episode_rating_count,
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

  def self.update_ttdb_show_data(ttdbid)
    puts "updating TTDB data for " + Tvshow.where(:ttdb_show_id => ttdbid).first.ttdb_show_title
    ttdbdata = get_series_from_ttdb(ttdbid)
    show = Tvshow.where(:ttdb_show_id => ttdbid).first
    #setup show data
    ttdb_show_title = ttdbdata['Series'].first['SeriesName'].first
    ttdb_show_imdb_id = ttdbdata['Series'].first['IMDB_ID'].first
    ttdb_show_overview = ttdbdata['Series'].first['Overview'].first
    ttdb_show_last_updated = ttdbdata['Series'].first['lastupdated'].first
    ttdb_show_banner = ttdbdata['Series'].first['banner'].first
    ttdb_show_fanart = ttdbdata['Series'].first['fanart'].first
    ttdb_show_poster = ttdbdata['Series'].first['poster'].first
    ttdb_show_rating = ttdbdata['Series'].first['Rating'].first
    ttdb_show_rating_count = ttdbdata['Series'].first['RatingCount'].first
    ttdb_show_network = ttdbdata['Series'].first['Network'].first
    ttdb_show_status = ttdbdata['Series'].first['Status'].first
    ttdb_show_runtime = ttdbdata['Series'].first['Runtime'].first
    #update show data
    show.update_attributes(
      :ttdb_show_imdb_id => ttdb_show_imdb_id,
      :ttdb_show_last_updated => ttdb_show_last_updated,
      :ttdb_show_banner => ttdb_show_banner,
      :ttdb_show_fanart => ttdb_show_fanart,
      :ttdb_show_poster => ttdb_show_poster,
      :ttdb_show_overview => ttdb_show_overview,
      :ttdb_show_title => ttdb_show_title,
      :ttdb_show_rating => ttdb_show_rating,
      :ttdb_show_rating_count => ttdb_show_rating_count,
      :ttdb_show_network => ttdb_show_network,
      :ttdb_show_status => ttdb_show_status,
      :ttdb_show_runtime => ttdb_show_runtime
      )
  end

  def self.update_ttdb_episode_data(ttdbid)
    ttdbdata = get_episode_from_ttdb(ttdbid)
    episode = Episode.where(:ttdb_episode_id => ttdbid).first
    print "Updating TTDB data for Episode: "
    print episode.tvshow.ttdb_show_title
    print " - "
    print episode.ttdb_season_number
    print " "
    puts episode.ttdb_episode_number
    #setup episode data
    ttdb_episode_title = ttdbdata['Episode'].first['EpisodeName'].first
    ttdb_season_number = ttdbdata['Episode'].first['SeasonNumber'].first
    ttdb_episode_number = ttdbdata['Episode'].first['EpisodeNumber'].first
    ttdb_episode_id = ttdbdata['Episode'].first['id'].first
    ttdb_episode_overview = ttdbdata['Episode'].first['Overview'].first
    ttdb_episode_last_updated = ttdbdata['Episode'].first['lastupdated'].first
    ttdb_show_id = ttdbdata['Episode'].first['seriesid'].first
    ttdb_episode_airdate = ttdbdata['Episode'].first['FirstAired'].first
    ttdb_episode_rating = ttdbdata['Episode'].first['Rating'].first
    ttdb_episode_rating_count = ttdbdata['Episode'].first['RatingCount']
    #update episode data
    episode.update_attributes(
      :ttdb_episode_title =>ttdb_episode_title,
      :ttdb_season_number => ttdb_season_number,
      :ttdb_episode_number => ttdb_episode_number,
      :ttdb_episode_id => ttdb_episode_id,
      :ttdb_episode_overview => ttdb_episode_overview,
      :ttdb_episode_last_updated => ttdb_episode_last_updated,
      :ttdb_show_id => ttdb_show_id,
      :ttdb_episode_airdate => ttdb_episode_airdate,
      :ttdb_episode_rating => ttdb_episode_rating,
      :ttdb_episode_rating_count => ttdb_episode_rating_count
      )
  end

  def self.update_tvrage_data
    Tvshow.all.each do |tvshow|
      next if tvshow.tvr_show_status == "Canceled/Ended"
      next if tvshow.tvr_show_status == "Ended"
      next if tvshow.tvr_show_status == "Canceled"
      puts "Updating TVR for: " + tvshow.ttdb_show_title
      tvragedata = get_tvrage_data(tvshow.ttdb_show_title)
      #prepare tvr data
      tvr_show_id = tvragedata['Show ID']
      #Process latest/next tvrage episode info
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
      tvr_show_url = tvragedata['Show URL']
      tvr_show_started = tvragedata['Started']
      tvr_show_ended = tvragedata['Ended']
      tvr_show_status = tvragedata['Status']
      #update tvr data
      tvshow.update_attributes(
        :tvr_show_id => tvr_show_id,
        :tvr_latest_season_number => tvr_latest_season_number,
        :tvr_latest_episode_number => tvr_latest_episode_number,
        :tvr_latest_episode_title => tvr_latest_episode_title,
        :tvr_latest_episode_date => tvr_latest_episode_date,
        :tvr_next_season_number => tvr_next_season_number,
        :tvr_next_episode_number => tvr_next_episode_number,
        :tvr_next_episode_title => tvr_next_episode_title,
        :tvr_next_episode_date => tvr_next_episode_date,
        :tvr_show_url => tvr_show_url,
        :tvr_show_started => tvr_show_started,
        :tvr_show_ended => tvr_show_ended,
        :tvr_show_status => tvr_show_status
        )
    end
  end
end

