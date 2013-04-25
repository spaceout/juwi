CONFIG = YAML.load_file(File.join(Rails.root,'/settings/settings.yml'))["config"]

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


