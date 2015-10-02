namespace :jdb do
  desc "This gets all new additions from XDB as well as removes shows from JDB that have been removed from XDB"
  task :update => :environment do
    require 'jdb_helper'
    require 'ttdb_helper'

    xbmcdb = Sequel.connect(Setting.get_value('xbmcdb'))
    xdbtvshows = xbmcdb[:tvshow]
    xdbepisodes = xbmcdb[:episode]
    last_xdb_episode_id = Setting.get_value("last_xdb_episode_id")
    last_xdb_show_id = Setting.get_value("last_xdb_show_id")

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
        ep = Tvshow.find_by_xdb_id(episode[:idShow]).episodes.where(:season_num => episode[:c12], :episode_num => episode[:c13]).first
        ep.sync(episode[:idEpisode])
      end
    end
    Setting.set_value("last_xdb_episode_id", xdbepisodes.order(:idEpisode).last[:idEpisode])

    #Remove shows deleted from XBMC
    puts "Checking for removed TV Shows"
    jdb_show_ids = Tvshow.pluck(:xdb_id)
    xdb_show_ids =  XdbHelper.get_all_show_ids
    removed_show_ids = jdb_show_ids - xdb_show_ids
    removed_show_ids.each do |xdbid|
      Tvshow.find_by_xdb_id(xdbid).destroy
    end

    #Remove episodes deleted from XBMC
    puts "Checking for removed Episodes"
    jdb_ep_ids = Episode.where("xdb_id IS NOT NULL").pluck(:xdb_id)
    xdb_ep_ids = XdbHelper.get_all_ep_ids
    removed_ep_ids = jdb_ep_ids - xdb_ep_ids
    removed_ep_ids.each do |xdbid|
      rem_ep = Episode.find_by_xdb_id(xdbid)
      puts "clearing XDB info on #{episode.tvshow.title} - #{episode.season_num} #{episode.episode_num}"
      rem_ep.clear_sync
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
    puts "Checking TV shows"
    xbmcdb = Sequel.connect(Setting.get_value('xbmcdb'))
    xdbtvshows = xbmcdb[:tvshow]
    xdbepisodes = xbmcdb[:episode]
    xdbtvshows.each do |tvshow|
      if Tvshow.where(:xdb_id => tvshow[:idShow]).empty?
        puts "Importing #{tvshow[:c00]}"
        Tvshow.new(tvshow[:c12]).create_new_show
      end
    end
    puts "Checking Episodes"
    xdbepisodes.each do |episode|
      if Episode.find_by_xdb_id(episode[:idEpisode]).nil?
        puts "Importing #{episode[:c00]}"
        #Episode.where(:xdb_id => episode[:idEpisode], :season_num => episode[:c12], :episode_num => [:c13]).first.sync(episode[:idEpisode])
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

  desc "this will process the files in the finished folder *BREAKS TORRENT TRACKER*"
  task :process_finished => :environment do
    require 'file_manipulator'
    require 're_namer'
    FileManipulator.process_finished_directory
    Dir.chdir(Setting.get_value("finished_path"))
    video_extensions = Setting.get_value("video_extensions").gsub('.','')
    Dir.glob("*.{#{video_extensions}}").each do |dir_entry|
      puts dir_entry
      Renamer.process_file(dir_entry)
    end
  end


  desc "fuck string encoding"
  task :fuck_encoding => :environment do
    blerm = []
    Episode.all.each do |episode|
      filename = episode.xdb_episode_location
      next if filename.nil?
      filename.force_encoding "utf-8"
      unless filename.valid_encoding?
        puts "#{episode.id} is stupid, see? -> #{episode.xdb_episode_location}"
        episode.update_attributes(:xdb_episode_location => nil)
      end
    end
  end




end
