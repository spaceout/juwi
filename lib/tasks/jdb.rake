CONFIG = YAML.load_file(File.join(Rails.root,'/settings/settings.yml'))["config"]
namespace :jdb do
desc "This gets all new additions from XDB as well as removes shows from JDB that have been removed from XDB"
task :update => :environment do
  require 'sequel'
  require 'mysql'
  require 'data_runner'

  xbmcdb = Sequel.connect(CONFIG['xbmcdb'])
  xdbtvshows = xbmcdb[:tvshow]
  xdbepisodes = xbmcdb[:episode]
  last_xdb_show_id = Settings.where(:name => "last_xdb_show_id").first.value
  last_xdb_episode_id = Settings.where(:name => "last_xdb_episode_id").first.value

  #Search for new XDB series
  puts "Searching for new Shows in XDB"
  new_shows = xdbtvshows.where("idShow > #{last_xdb_show_id}")
  unless new_shows.empty?
    new_shows.each do |show|
      DataRunner.import_new_show_from_xdb(show[:idShow])
    end
    Settings.where(:name => "last_xdb_show_id").first.update_attributes(:value => xdbtvshows.order(:idShow).last[:idShow])
  end

  #Search and sync newly added XDB episodes
  puts "Searching for new episodes in XDB"
  new_episodes = xdbepisodes.where("idEpisode > #{last_xdb_episode_id}")
  unless new_episodes.empty?
    new_episodes.each do |episode|
      DataRunner.sync_episode_data(episode[:idEpisode])
    end
    Settings.where(:name => "last_xdb_episode_id").first.update_attributes(:value => xdbepisodes.order(:idEpisode).last[:idEpisode])
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

desc "This checks sync with XDB"
task :verify => :environment do
  require 'sequel'
  require 'mysql'
  require 'data_runner'

  xbmcdb = Sequel.connect(CONFIG['xbmcdb'])
  xdbtvshows = xbmcdb[:tvshow]
  xdbtvshows.each do |tvshow|
    if Tvshow.where(:xdb_show_id => tvshow[:idShow]).empty?
      puts "Importing #{tvshow[:c00]}"
      DataRunner.import_new_show_from_xdb(tvshow[:idShow])
    end
  end
end

desc "This synch up the rest of the episode info"
task :syncData => :environment do
  require 'sequel'
  require 'mysql'
  require 'data_runner'

  xbmcdb = Sequel.connect(CONFIG['xbmcdb'])
  xdbepisodes = xbmcdb[:episode]
  xdbepisodes.each do |episode|
    DataRunner.sync_episode_data(episode[:idEpisode])
  end
  xbmcdb.disconnect
end


end
