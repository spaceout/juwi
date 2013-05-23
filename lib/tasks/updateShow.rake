TTDBCACHE = File.join(Rails.root,'/ttdbdata/')
CONFIG = YAML.load_file(File.join(Rails.root,'/settings/settings.yml'))["config"]
namespace :jdb do
  desc "This refreshes all data for a single show passed in as argument"
  task :updateShow, [:showname] => :environment do |t, args|
    require 'mysql'
    require 'sequel'
    require 'data_runner'
    xbmcdb = Sequel.connect(CONFIG['xbmcdb'])
    xdbtvshows = xbmcdb[:tvshow]
    xdbepisodes = xbmcdb[:episode]
    showname = args[:showname] || 'none'
    puts "Searching for #{showname} in JDB"
    currentshow = Tvshow.where(:ttdb_show_title => showname)
    if currentshow.empty?
      puts "No Show Found matching #{showname}"
    else
      show_ttdbid = currentshow.first.ttdb_show_id
      show_xdbid = currentshow.first.xdb_show_id
      puts "Found #{showname} in JDB TTDBID = #{show_ttdbid} XDBID = #{show_xdbid}"
      currentshow.first.destroy
      puts "removed #{showname} from JDB"
      File.delete("#{TTDBCACHE}#{show_ttdbid}.zip")
      puts "deleted TTDB zip cache file"
      puts "getting zip and importing show"
      DataRunner.import_new_show_from_xdb(show_xdbid)
      puts "syncing episode data form XDB to JDB"
      xdbepisodes.where("idShow = #{show_xdbid}").each do |episode|
        DataRunner.sync_episode_data(episode[:idEpisode])
      end
      puts "updating TVR data for #{showname}"
      updatedshow = Tvshow.where(:ttdb_show_title => showname).first
      TvrHelper.update_tvrage_data(updatedshow.ttdb_show_title, updatedshow.id)
    end
    xbmcdb.disconnect
    puts "Completed drop and re-import of #{showname}"
  end
end

