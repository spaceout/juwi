namespace :jdb do
  desc "This gets all new additions from XDB as well as removes shows from JDB that have been removed from XDB"
  task :update => :environment do
    require 'sequel'
    require 'mysql'
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
        show_ttdbid = show[:c12]
        show_xdbid = show[:idShow]
        TtdbHelper.get_zip_from_ttdb(show_ttdbid)
        TtdbHelper.update_ttdb_show_data(show_ttdbid)
        TtdbHelper.update_all_ttdb_episode_data(show_ttdbid)
        JdbHelper.update_jdb_show_data(show_ttdbid)
        TvrHelper.update_tvrage_data(show_ttdbid)
        xdbepisodes.where("idShow = #{show_xdbid}").each do |episode|
          JdbHelper.sync_episode_data(episode[:idEpisode])
        end
      end
      Setting.set_value("last_xdb_show_id", xdbtvshows.order(:idShow).last[:idShow])
    end

    #Search and sync newly added XDB episodes
    puts "Searching for new episodes in XDB"
    new_episodes = xdbepisodes.where("idEpisode > #{last_xdb_episode_id}")
    unless new_episodes.empty?
      new_episodes.each do |episode|
        JdbHelper.sync_episode_data(episode[:idEpisode])
      end
      Setting.set_value("last_xdb_episode_id", xdbepisodes.order(:idEpisode).last[:idEpisode])
    end

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
        episode.update_attributes(
          :xdb_episode_id => nil,
          :xdb_episode_location => nil
          )
      end
    end
  xbmcdb.disconnect
  end

  desc "This refreshes all data for a single show passed in as argument"
  task :update_show, [:showname] => :environment do |t, args|
    require 'jdb_helper'
    showname = args[:showname] || 'none'
    JdbHelper.update_show(showname)
  end


  desc "This checks sync with XDB"
  task :verify => :environment do
    require 'sequel'
    require 'mysql'

    xbmcdb = Sequel.connect(Setting.get_value('xbmcdb'))
    xdbtvshows = xbmcdb[:tvshow]
    xdbtvshows.each do |tvshow|
      if Tvshow.where(:xdb_show_id => tvshow[:idShow]).empty?
        puts "Importing #{tvshow[:c00]}"
        DataRunner.import_new_show_from_xdb(tvshow[:idShow])
      end
    end
    xbmcdb.disconnect
  end

  desc "This synch up the rest of the episode info"
  task :syncData => :environment do
    require 'sequel'
    require 'mysql'

    xbmcdb = Sequel.connect(Setting.get_value('xbmcdb'))
    xdbepisodes = xbmcdb[:episode]
    xdbepisodes.each do |episode|
      DataRunner.sync_episode_data(episode[:idEpisode])
    end
    xbmcdb.disconnect
  end

  desc "Create the jdb_clean_show_name data for all tvshows"
  task :createCleanShowData => :environment do
    require 'scrubber'
    Tvshow.all.each do |show|
      clean_show_title = Scrubber.clean_show_title(show.ttdb_show_title)
      puts "Original: #{show.ttdb_show_title} Clean: #{clean_show_title}"
      show.update_attributes(
        :jdb_clean_show_title => clean_show_title
      )
    end
  end
end
