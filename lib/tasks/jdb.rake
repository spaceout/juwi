namespace :jdb do
  desc "This gets all new additions from XDB as well as removes shows from JDB that have been removed from XDB"
  task :update => :environment do
    require 'jdb_helper'
    JdbHelper.sync_xdb_to_jdb
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
    xbmcdb = Sequel.connect(Settings.xbmcdb)
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
    Dir.chdir(Settings.finished_path)
    video_extensions = Settings.video_extensions.gsub('.','')
    Dir.glob("*.{#{video_extensions}}").each do |dir_entry|
      puts dir_entry
      Renamer.process_file(dir_entry)
    end
  end

  desc "This does initial population of the DB based on contents of XBMC"
  task :populate => :environment do
    require 'jdb_helper'
    JdbHelper.populate
  end

end
