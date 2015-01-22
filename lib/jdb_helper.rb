class JdbHelper

  def self.update_show(showname)
    puts "Searching for #{showname} in JDB"
    currentshow = Tvshow.find_by_ttdb_show_title(showname)
    if currentshow.nil?
      puts "No Show Found matching #{showname}"
    else
      currentshow.destroy
      puts "#{showname} destroyed"
      ttdb_show_id = currentshow.ttdb_show_id
      Tvshow.create_and_sync_new_show(ttdb_show_id)
    end
    puts "Completed drop and re-import of #{showname}"
  end

  def self.xdbid_to_ttdbid(xdbid)
    xbmcdb = Sequel.connect(Setting.get_value('xbmcdb'))
    xdbtvshows = xbmcdb[:tvshow]
    ttdbid = xdbtvshows.where("idShow = #{xdbid}").first[:c12]
    xbmcdb.disconnect
    return ttdbid
  end

  def self.ttdbid_to_xdbid(ttdb_id)
    xbmcdb = Sequel.connect(Setting.get_value('xbmcdb'))
    xdbtvshows = xbmcdb[:tvshow]
    xdbid = xdbtvshows.where("c12 = #{ttdb_id}").first[:idShow]
    xbmcdb.disconnect
    return xdbid
  end

end

