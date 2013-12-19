namespace :jdb do
  desc "This will populate the data from cache zip files"
  task :importData => :environment do
    require 'xmlsimple'
    require 'sequel'
    require 'mysql'

    xbmcdb = Sequel.connect(Setting.get_value('xbmcdb'))
    xdbtvshows = xbmcdb[:tvshow]
    xdbepisodes = xbmcdb[:episode]
    #set initial scrape time for ttdb
    ttdbtime = TtdbHelper.get_time_from_ttdb
    #import every show
    xdbtvshows.each do |show|
      DataRunner.import_new_show_from_xdb(show[:idShow])
    end
    #Update last show/episode and time scrapped from xdb
    Setting.set_value("last_xdb_show_id", xdbtvshows.order(:idShow).last[:idShow])
    Setting.set_value("last_xdb_episode_id", xdbepisodes.order(:idEpisode).last[:idEpisode])
    Setting.set_value("xdb_last_scrape", DateTime.current)
    Setting.set_value("ttdb_last_scrape", ttdbtime)
    xbmcdb.disconnect
  end
end
