# encoding: utf-8
# Create File when downloading cache and put last update time in there
# Split data from tvr_latest_episode into all three columns
# Split Data form tvr_next_episode into all three columns
#
TTDBCACHE = File.join(Rails.root,'/ttdbdata/')
XBMCDB = 'mysql://xbmc:xbmc@192.168.1.8/MyVideos75'

desc "This will populate the data from cache zip files"
task :importData => :environment do
  require 'xmlsimple'
  require 'sequel'
  require 'mysql'
  require 'data_runner'

  xbmcdb = Sequel.connect(XBMCDB)
  xdbtvshows = xbmcdb[:tvshow]
  xdbepisodes = xbmcdb[:episode]
  #set initial scrape time for ttdb
  ttdbtime = DataRunner.get_time_from_ttdb
  #create file for cache ttdb time
  if File.exist?("#{TTDBCACHE}updatetime")
    oldcachetime = File.open("#{TTDBCACHE}updatetime", 'r') { |f| f.read }
    Settings.where(:name => "ttdb_last_scrape").first.update_attributes(:value => oldcachetime)
  else
    Settings.where(:name => "ttdb_last_scrape").first.update_attributes(:value => ttdbtime)
    File.open("#{TTDBCACHE}updatetime", 'w') {|f| f.write(ttdbtime) }
  end
  #import every show
  xdbtvshows.each do |show|
    DataRunner.import_new_show_from_xdb(show[:idShow])
  end
  #Update last show/episode and time scrapped from xdb
  Settings.where(:name => "last_xdb_show_id").first.update_attributes(:value => xdbtvshows.order(:idShow).last[:idShow])
  Settings.where(:name => "last_xdb_episode_id").first.update_attributes(:value => xdbepisodes.order(:idEpisode).last[:idEpisode])
  Settings.where(:name => "xdb_last_scrape").first.update_attributes(:value => DateTime.current)
  xbmcdb.disconnect
end

desc "This synch up the rest of the episode info"
task :syncData => :environment do
  require 'sequel'
  require 'mysql'
  require 'data_runner'

  xbmcdb = Sequel.connect(XBMCDB)
  xdbepisodes = xbmcdb[:episode]
  xdbepisodes.each do |episode|
    DataRunner.sync_episode_data(episode[:idEpisode])
  end
  xbmcdb.disconnect
end

desc "This updates from xdb and ttdb"
task :updateData => :environment do
  require 'sequel'
  require 'mysql'
  require 'data_runner'

  xbmcdb = Sequel.connect(XBMCDB)
  xdbtvshows = xbmcdb[:tvshow]
  xdbepisodes = xbmcdb[:episode]
  last_xdb_show_id = Settings.where(:name => "last_xdb_show_id").first.value
  last_xdb_episode_id = Settings.where(:name => "last_xdb_episode_id").first.value

  #Search for new XDB series
  new_shows = xdbtvshows.where("idShow > #{last_xdb_show_id}")
  unless new_shows.empty?
    new_shows.each do |show|
      DataRunner.import_new_show_from_xdb(show[:idShow])
    end
    Settings.where(:name => "last_xdb_show_id").first.update_attributes(:value => xdbtvshows.order(:idShow).last[:idShow])
  end

  #Get updates from ttdb
  updatedata = DataRunner.get_updates_from_ttdb(Settings.where(:name => "ttdb_last_scrape").first.value)

  #Check if we have any of the shows in the ttdb update xml that are to be updated
  unless updatedata["Series"].nil?
    updatedata["Series"].each do |series|
      next if Tvshow.where(:ttdb_show_id => series).empty?
      DataRunner.update_ttdb_show_data(series)
    end
  end

  #check if we have any episodes in the ttdb update xml that are to be updated
  unless updatedata["Episode"].nil?
    updatedata["Episode"].each do |episode|
      next if Episode.where(:ttdb_episode_id => episode).empty?
      DataRunner.update_ttdb_episode_data(episode)
    end
  end

  #Search and sync newly added XDB episodes
  new_episodes = xdbepisodes.where("idEpisode > #{last_xdb_episode_id}")
  unless new_episodes.empty?
    new_episodes.each do |episode|
      DataRunner.sync_episode_data(episode[:idEpisode])
    end
    Settings.where(:name => "last_xdb_episode_id").first.update_attributes(:value => xdbepisodes.order(:idEpisode).last[:idEpisode])
  end

  #Reset last update time
  Settings.where(:name => "ttdb_last_scrape").first.update_attributes(:value => updatedata["Time"].first)
  xbmcdb.disconnect
end

desc "This updates tvrage data"
task :updateRageData => :environment do
  require 'data_runner'
  DataRunner.update_tvrage_data
end

desc "This will check for any changes to XDB that have to remove stuff from JDB"
task :xdbvsjdb => :environment do
  require 'data_runner'
  require 'mysql'
  require 'sequel'

   xbmcdb = Sequel.connect(XBMCDB)
   xdbtvshows = xbmcdb[:tvshow]
   xdbepisodes = xbmcdb[:episode]
   Tvshow.all.each do |tvshow|
     if xdbtvshows.filter(:c12 => tvshow.ttdb_show_id).empty?
       puts "deleting #{tvshow.ttdb_show_title} from JDB"
       tvshow.destroy
     end
   end
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
end

