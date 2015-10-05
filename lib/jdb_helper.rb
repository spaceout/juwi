class JdbHelper

  def self.update_show(showname)
    puts "Searching for #{showname} in JDB"
    currentshow = Tvshow.find_by_title(showname)
    if currentshow.nil?
      puts "No Show Found matching #{showname}"
      return
    else
      ttdb_id = currentshow.ttdb_id
      currentshow.destroy
      puts "#{showname} destroyed"
      Tvshow.new(ttdb_id: ttdb_id).create_new_show
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

  def self.sync_xdb_to_jdb
    require 'xdb_helper'
    require 'jdb_helper'
    require 'ttdb_helper'

    xbmcdb = Sequel.connect(Setting.get_value('xbmcdb'))
    xdbtvshows = xbmcdb[:tvshow]
    xdbepisodes = xbmcdb[:episode]
    last_xdb_episode_id = Setting.get_value("last_xdb_episode_id")
    last_xdb_show_id = Setting.get_value("last_xdb_show_id")

    #pluckify with xdb_helper
    xdb_shows = XdbHelper.get_all_show_ids
    xdb_eps = XdbHelper.get_all_ep_ids
    jdb_shows = Tvshow.pluck(:xdb_id)
    jdb_eps = Episode.where("xdb_id IS NOT NULL").pluck(:xdb_id)

    new_shows = xdb_shows - jdb_shows
    removed_shows = jdb_shows - xdb_shows
    new_eps = xdb_eps - jdb_eps
    removed_eps = jdb_eps - xdb_eps

    puts "Searching for new Shows in XDB"
    new_shows = xdbtvshows.where("idShow > #{last_xdb_show_id}")
    unless new_shows.empty?
      new_shows.each do |show|
        ttdb_id = show[:c12]
        new_show = Tvshow.find_or_initialize_by_ttdb_id(ttdb_id)
        new_show.create_new_show
        puts "Found New Show: #{new_show.title}"
      end
    end
    Setting.set_value("last_xdb_show_id", xdbtvshows.order(:idShow).last[:idShow])

    puts "Searching for new episodes in XDB"
    unless new_episodes.empty?
      new_episodes.each do |episode|
        ep = Tvshow.find_by_xdb_id(episode[:idShow]).episodes.where(:season_num => episode[:c12], :episode_num => episode[:c13]).first
        if ep.nil?
          puts "problem syncing episode xdbID: #{episode[:idEpisode]}"
          next
        else
          ep.sync(episode[:idEpisode])
        end
        print "Found New Episode: "
        puts ep.tvshow.title + " - " + "s" '%02d' % ep.season_num + "e" + '%02d' % ep.episode_num + " - " + ep.title
      end
    end
    Setting.set_value("last_xdb_episode_id", xdbepisodes.order(:idEpisode).last[:idEpisode])

    puts "Checking for removed TV Shows"
    jdb_show_ids = Tvshow.pluck(:xdb_id)
    xdb_show_ids =  XdbHelper.get_all_show_ids
    removed_show_ids = jdb_show_ids - xdb_show_ids
    removed_show_ids.each do |xdbid|
      tvshow = Tvshow.find_by_xdb_id(xdbid)
      puts "Removing Show: #{tvshow.title}"
      tvshow.destroy
    end

    puts "Checking for removed Episodes"
    jdb_ep_ids = Episode.where("xdb_id IS NOT NULL").pluck(:xdb_id)
    xdb_ep_ids = XdbHelper.get_all_ep_ids
    removed_ep_ids = jdb_ep_ids - xdb_ep_ids
    removed_ep_ids.each do |xdbid|
      rem_ep = Episode.find_by_xdb_id(xdbid)
      print "Clearing XDB info on: "
      puts rem_ep.tvshow.title + " - " + "s" '%02d' % rem_ep.season_num + "e" + '%02d' % rem_ep.episode_num + " - " + rem_ep.title
      rem_ep.clear_sync
    end
    xbmcdb.disconnect
  end

end
