TTDBCACHE = File.join(Rails.root,'/ttdbdata/')
CONFIG = YAML.load_file(File.join(Rails.root,'/settings/settings.yml'))["config"]

desc "This will check for any changes to XDB that have to remove stuff from JDB"
task :xdbvsjdb => :environment do
  require 'data_runner'
  require 'mysql'
  require 'sequel'

  xbmcdb = Sequel.connect(CONFIG['xbmcdb'])
  xdbtvshows = xbmcdb[:tvshow]
  xdbepisodes = xbmcdb[:episode]

  Tvshow.all.each do |tvshow|
    if xdbtvshows.filter(:idShow => tvshow.xdb_show_id).empty?
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
  xbmcdb.disconnect
end


