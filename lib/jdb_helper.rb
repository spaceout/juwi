class JdbHelper
  def self.update_show(showname)
    require 'mysql'
    require 'sequel'
    require 'data_runner'
    xbmcdb = Sequel.connect(CONFIG['xbmcdb'])
    xdbepisodes = xbmcdb[:episode]
    puts "Searching for #{showname} in JDB"
    currentshow = Tvshow.where(:ttdb_show_title => showname)
    if currentshow.empty?
      puts "No Show Found matching #{showname}"
    else
      show_ttdbid = currentshow.first.ttdb_show_id
      show_xdbid = currentshow.first.xdb_show_id
      puts "Found #{showname} in JDB TTDBID = #{show_ttdbid} XDBID = #{show_xdbid}"
      File.delete("#{TTDBCACHE}#{show_ttdbid}.zip")
      puts "deleted TTDB zip cache file"
      puts "getting zip and importing show"
      DataRunner.import_new_show_from_xdb(show_xdbid)
      puts "syncing episode data form XDB to JDB"
      xdbepisodes.where("idShow = #{show_xdbid}").each do |episode|
        DataRunner.sync_episode_data(episode[:idEpisode])
      end
    end
    xbmcdb.disconnect
    puts "Completed drop and re-import of #{showname}"
  end
end

