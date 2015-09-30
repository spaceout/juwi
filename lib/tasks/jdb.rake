namespace :jdb do
  desc "This gets all new additions from XDB as well as removes shows from JDB that have been removed from XDB"
  task :update => :environment do
    require 'jdb_helper'
    require 'ttdb_helper'

    xbmcdb = Sequel.connect(Setting.get_value('xbmcdb'))
    xdbtvshows = xbmcdb[:tvshow]
    xdbepisodes = xbmcdb[:episode]
    last_xdb_episode_id = Setting.get_value("last_xdb_show_id")
    last_xdb_show_id = Setting.get_value("last_xdb_episode_id")

    #Search for new XDB series
    puts "Searching for new Shows in XDB"
    new_shows = xdbtvshows.where("idShow > #{last_xdb_show_id}")
    unless new_shows.empty?
      new_shows.each do |show|
        ttdb_id = show[:c12]
        Tvshow.find_or_initialize_by_ttdb_id(ttdb_id).create_new_show
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
      if xdbtvshows.filter(:idShow => tvshow.xdb_id).empty?
        puts "deleting #{tvshow.title} from JDB"
        tvshow.destroy
      end
    end

    #Remove episodes deleted from XBMC
    puts "Checking for removed Episodes"
    Episode.all.each do |episode|
      next if episode.xdb_id.nil?
      if xdbepisodes.filter(:idEpisode => episode.xdb_id).empty?
        puts "clearing XDB info on #{episode.tvshow.title} - #{episode.season_num} #{episode.episode_num}"
        Tvshow.remove_xdb_episode_data(episode.ttdb_id)
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
      if Tvshow.where(:xdb_id => tvshow[:idShow]).empty?
        puts "Importing #{tvshow[:c00]}"
        Tvshow.create_and_sync_new_show(tvshow[:c12])
      end
    end
    puts "Checking Episodes"
    xdbepisodes.each do |episode|
      if Episode.find_by_xdb_id(episode[:idEpisode]).nil?
        puts "Importing #{episode[:c00]}"
        Tvshow.update_xdb_episode_data(episode[:idEpisode])
      end
    end
    xbmcdb.disconnect
  end

  desc "this will update the forcast data"
  task :update_forcast => :environment do
    Tvshow.all.each do |tvshow|
      puts "updating #{tvshow.title}"
      tvshow.update_next_episode
      tvshow.update_latest_episode
    end
  end
end
