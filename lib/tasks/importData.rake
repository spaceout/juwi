
TTDBCACHE = File.join(Rails.root,'/ttdbdata/')
CONFIG = YAML.load_file(File.join(Rails.root,'/settings/settings.yml'))["config"]
namespace :jdb do
desc "This will populate the data from cache zip files"
task :importData => :environment do
  require 'xmlsimple'
  require 'sequel'
  require 'mysql'
  require 'data_runner'

  xbmcdb = Sequel.connect(CONFIG['xbmcdb'])
  xdbtvshows = xbmcdb[:tvshow]
  xdbepisodes = xbmcdb[:episode]
  #set initial scrape time for ttdb
  ttdbtime = TtdbHelper.get_time_from_ttdb
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
# FIXME: blah blah blah
end
