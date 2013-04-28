require 'ttdb_helper'
require 'tvr_helper'

TTDBCACHE = File.join(Rails.root,'/ttdbdata/')
CONFIG = YAML.load_file(File.join(Rails.root,'/settings/settings.yml'))["config"]

class DataRunner

  def self.import_new_show_from_xdb(showid)
    xbmcdb = Sequel.connect(CONFIG['xbmcdb'])
    xdbtvshows = xbmcdb[:tvshow]
    show = xdbtvshows.where("idShow = #{showid}").first
    #Get ttdb xml data if not in cache
    if File.exist?(TTDBCACHE + show[:c12] +".zip") == false
      puts "downloading " + show[:c00]
      TtdbHelper.get_zip_from_ttdb(show[:c12])
    end
    ttdbdata = TtdbHelper.ttdb_xml_show_data("#{TTDBCACHE}#{show[:c12]}.zip", "en.xml")
    #Get TVRage data
    tvragedata = TvrHelper.get_tvrage_data(ttdbdata['Series'].first['SeriesName'].first.to_s)
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
    currentShow = Tvshow.find_or_initialize_by_ttdb_show_id(ttdb_show_id)
    currentShow.update_attributes(
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
      currentEpisode = currentShow.episodes.find_or_initialize_by_ttdb_episode_id(ttdb_episode_id)
      currentEpisode.update_attributes(
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
    xbmcdb = Sequel.connect(CONFIG['xbmcdb'])
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
    ttdbdata = TtdbHelper.get_series_from_ttdb(ttdbid)
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
    ttdbdata = TtdbHelper.get_episode_from_ttdb(ttdbid)
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
      sanitized_title = tvshow.ttdb_show_title.split("(").first
      tvragedata = TvrHelper.get_tvrage_data(sanitized_title)
      #prepare tvr data
      tvr_show_id = tvragedata['Show ID']
      tvr_show_url = tvragedata['Show URL']
      tvr_show_started = tvragedata['Started']
      tvr_show_ended = tvragedata['Ended']
      tvr_show_status = tvragedata['Status']
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
      puts tvr_show_status
      #update tvr data
      if tvshow.update_attributes(
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
        puts "Updated Successfully"
      else
        puts "Error Updating record"
        puts tvshow.errors
      end
    end
  end
end
