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

    xdb_shows = XdbHelper.get_all_show_ttdb_ids
    xdb_eps = XdbHelper.get_all_ep_ids
    jdb_shows = Tvshow.pluck(:ttdb_id)
    jdb_eps = Episode.where("xdb_id IS NOT NULL").pluck(:xdb_id)

    new_shows = xdb_shows - jdb_shows
    removed_shows = jdb_shows - xdb_shows
    new_eps = xdb_eps - jdb_eps
    removed_eps = jdb_eps - xdb_eps

    new_eps_data = XdbHelper.get_multiple_ep_data(new_eps) unless new_eps.nil?

    puts "Searching for new Shows in XDB"
    unless new_shows.empty?
      new_shows.each do |show|
        new_show = Tvshow.find_or_initialize_by_ttdb_id(show)
        new_show.create_new_show
        puts "Found New Show: #{new_show.title}"
      end
    end
    puts "Searching for new episodes in XDB"
    unless new_eps.empty?

      new_eps_data.each do |ep|
        #puts ep
        tvshow = Tvshow.find_by_xdb_id(ep[:idShow])
        next if tvshow.nil?
        episode = tvshow.episodes.where(:season_num => ep[:c12], :episode_num => ep[:c13]).first
        if episode.nil?
          puts "Couldnt Find Episode xdbID: #{ep}"
          next
        else
          episode.sync(ep[:idEpisode])
        end
        print "Found New Episode: "
        puts episode.tvshow.title + " - " + "s" '%02d' % episode.season_num + "e" + '%02d' % episode.episode_num + " - " + episode.title
      end
    end
    puts "Checking for removed TV Shows"
    removed_shows.each do |ttdb_id|
      tvshow = Tvshow.find_by_ttdb_id(ttdb_id)
      puts "Removing Show: #{tvshow.title}"
      tvshow.destroy
    end
    puts "Checking for removed Episodes"
    removed_eps.each do |xdb_id|
      rem_ep = Episode.find_by_xdb_id(xdb_id)
      unless rem_ep.nil?
        print "Clearing XDB Ep #{rem_ep} info on: "
        puts rem_ep.tvshow.title + " - " + "s" '%02d' % rem_ep.season_num + "e" + '%02d' % rem_ep.episode_num + " - " + rem_ep.title
        rem_ep.clear_sync
      end
    end
  end

  def self.populate
    require 'xdb_helper'
    allshows = XdbHelper.get_all_show_ttdb_ids
    allshows.each do |show|
      new_show = Tvshow.find_or_initialize_by_ttdb_id(show)
      new_show.save
      new_show.delay.update_show
      puts new_show.title
    end
  end

end
