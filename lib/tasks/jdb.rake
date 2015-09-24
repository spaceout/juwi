namespace :jdb do
  desc "cleans up the TBA dupes"
  task :tba_fix => :environment do
    Episode.where(ttdb_episode_title: "TBA").each do |tba_episode|
      if tba_episode.tvshow.episodes.where(
        ttdb_season_number: tba_episode.ttdb_season_number,
        ttdb_episode_number: tba_episode.ttdb_episode_number
      ).where('ttdb_episode_title != ?', "TBA").count == 1
        puts "found match"
        puts tba_episode.inspect
      end
    end
  end

  desc "This gets all new additions from XDB as well as removes shows from JDB that have been removed from XDB"
  task :update => :environment do
    require 'jdb_helper'
    require 'ttdb_helper'
    require 'tvr_helper'

    xbmcdb = Sequel.connect(Setting.get_value('xbmcdb'))
    xdbtvshows = xbmcdb[:tvshow]
    xdbepisodes = xbmcdb[:episode]
    last_xdb_show_id = Setting.get_value("last_xdb_show_id")
    last_xdb_episode_id = Setting.get_value("last_xdb_episode_id")

    #Search for new XDB series
    puts "Searching for new Shows in XDB"
    new_shows = xdbtvshows.where("idShow > #{last_xdb_show_id}")
    unless new_shows.empty?
      new_shows.each do |show|
        ttdb_show_id = show[:c12]
        Tvshow.create_and_sync_new_show(ttdb_show_id)
      end
    end
    Setting.set_value("last_xdb_show_id", xdbtvshows.order(:idShow).last[:idShow])

    #Search and sync newly added XDB episodes
    puts "Searching for new episodes in XDB"
    new_episodes = xdbepisodes.where("idEpisode > #{last_xdb_episode_id}")
    unless new_episodes.empty?
      new_episodes.each do |episode|
        Tvshow.update_xdb_episode_data(episode[:idEpisode])
      end
    end
    Setting.set_value("last_xdb_episode_id", xdbepisodes.order(:idEpisode).last[:idEpisode])

    #Remove shows deleted from XBMC
    puts "Checking for removed TV Shows"
    Tvshow.all.each do |tvshow|
      if xdbtvshows.filter(:idShow => tvshow.xdb_show_id).empty?
        puts "deleting #{tvshow.ttdb_show_title} from JDB"
        tvshow.destroy
      end
    end

    #Remove episodes deleted from XBMC
    puts "Checking for removed Episodes"
    Episode.all.each do |episode|
      next if episode.xdb_episode_id.nil?
      if xdbepisodes.filter(:idEpisode => episode.xdb_episode_id).empty?
        puts "clearing XDB info on #{episode.tvshow.ttdb_show_title} - #{episode.ttdb_season_number} #{episode.ttdb_episode_number}"
        Tvshow.remove_xdb_episode_data(episode.ttdb_episode_id)
      end
    end
  xbmcdb.disconnect
  end

  desc "This refreshes all data for a single show passed in as argument"
  task :update_show, [:showname] => :environment do |t, args|
    require 'jdb_helper'
    showname = args[:showname] || 'none'
    #Tvshow.where(ttdb_show_name: "#{showname}").first.episodes.destroy
    JdbHelper.update_show(showname)
  end

  desc "This checks sync with XDB"
  task :verify => :environment do
    puts "Checking TV shows"
    xbmcdb = Sequel.connect(Setting.get_value('xbmcdb'))
    xdbtvshows = xbmcdb[:tvshow]
    xdbepisodes = xbmcdb[:episode]
    xdbtvshows.each do |tvshow|
      if Tvshow.where(:xdb_show_id => tvshow[:idShow]).empty?
        puts "Importing #{tvshow[:c00]}"
        Tvshow.create_and_sync_new_show(tvshow[:c12])
      end
    end
    puts "Checking Episodes"
    xdbepisodes.each do |episode|
      if Episode.find_by_xdb_episode_id(episode[:idEpisode]).nil?
        puts "Importing #{episode[:c00]}"
        Tvshow.update_xdb_episode_data(episode[:idEpisode])
      end
    end
    xbmcdb.disconnect
  end

  desc "This will populate the data from cache zip files"
  task :import_data => :environment do
    xbmcdb = Sequel.connect(Setting.get_value('xbmcdb'))
    xdbtvshows = xbmcdb[:tvshow]
    xdbepisodes = xbmcdb[:episode]
    ttdbtime = TtdbHelper.get_time_from_ttdb
    xdbtvshows.each do |show|
     Tvshow.create_and_sync_new_show(show[:c12])
    end
    Setting.set_value("last_xdb_show_id", xdbtvshows.order(:idShow).last[:idShow])
    Setting.set_value("last_xdb_episode_id", xdbepisodes.order(:idEpisode).last[:idEpisode])
    Setting.set_value("xdb_last_scrape", DateTime.current)
    Setting.set_value("ttdb_last_scrape", ttdbtime)
    xbmcdb.disconnect
  end

  desc "this will update the forcast data"
  task :update_forcast => :environment do
    Tvshow.all.each do |tvshow|
      puts "updating #{tvshow.ttdb_show_title}"
      tvshow.update_next_episode
      tvshow.update_latest_episode
    end
  end
end
