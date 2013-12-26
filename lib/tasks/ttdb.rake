namespace :ttdb do
  desc "This updates TTDB data for all shows"
  task :update => :environment do
    require 'jdb_helper'
    require 'ttdb_helper'

    puts "Getting updates XML from ttdb"
    updatedata = TtdbHelper.get_updates_from_ttdb
    unless updatedata["Series"].nil?
      update_set = []
      updatedata["Series"].each do |series|
        show_ttdbid = series['id'].first
        current_jdb_show = Tvshow.find_by_ttdb_show_id(show_ttdbid)
        next if current_jdb_show == nil
        next if current_jdb_show.tvr_show_status == "Canceled/Ended"
        next if current_jdb_show.tvr_show_status == "Ended"
        next if current_jdb_show.tvr_show_status == "Canceled"
        update_set.push(show_ttdbid)
      end
      puts "Updating #{update_set.count} Series"
      update_set.each do |ttdb_id| 
        TtdbHelper.update_all_ttdb_data(ttdb_id)
      end
    end
    #Reset last update time
    Setting.set_value("ttdb_last_scrape", updatedata["time"])
  end

  ####GET ALL TTDB IMAGES####
  desc "This will download all images for current tvshows"
  task :getImages => :environment do
    Tvshow.all.each do |tvshow|
      next if File.exist?(File.join(Rails.root, "/public/images/", "#{tvshow.ttdb_show_id}_banner.jpg"))
      TtdbHelper.get_all_images(tvshow)
    end
  end

  desc "This searches TTDB for showname and returns ttdb IDs"
  task :search_ttdb, [:showname] => :environment do |t, args|
    require 'ttdb_helper'
    showname = args[:showname] || 'none'
    puts TtdbHelper.search_ttdb(showname)
  end


end
