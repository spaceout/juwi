CONFIG = YAML.load_file(File.join(Rails.root,'/settings/settings.yml'))["config"]

desc "This updates from xdb and ttdb"
task :updateData => :environment do
  require 'sequel'
  require 'mysql'
  require 'data_runner'

  xbmcdb = Sequel.connect(CONFIG['xbmcdb'])
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
  #Figure out how long since last update
  current_time = TtdbHelper.get_time_from_ttdb.to_i
  last_update = Settings.where(:name => "ttdb_last_scrape").first.value.to_i
  time_since_last_update = current_time - last_update

  #Get updates from ttdb
  if time_since_last_update < 86400
    puts "Doing Daily Update"
    update_interval = 1
  elsif time_since_last_update < 604800
    puts "Doing Weekly Update"
    update_interval = 2
  elsif time_since_last_update < 18144000
    puts "Doing Monthly Update"
    update_interval = 3
  end

  updatedata = TtdbHelper.get_updates_from_ttdb(Settings.where(:name => "ttdb_last_scrape").first.value, update_interval)

  #Check if we have any of the shows in the ttdb update xml that are to be updated
  unless updatedata["Series"].nil?
    updatedata["Series"].each do |series|
      next if Tvshow.where(:ttdb_show_id => series["id"]).empty?
      DataRunner.update_ttdb_show_data(series["id"].first)
    end
  end

  #check if we have any episodes in the ttdb update xml that are to be updated
  unless updatedata["Episode"].nil?
    updatedata["Episode"].each do |episode|
      next if Episode.where(:ttdb_episode_id => episode["id"]).empty?
      DataRunner.update_ttdb_episode_data(episode["id"].first)
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
  Settings.where(:name => "ttdb_last_scrape").first.update_attributes(:value => updatedata["time"])
  xbmcdb.disconnect
end


