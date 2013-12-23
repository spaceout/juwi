namespace :ttdb do
  desc "This updates TTDB data for all shows"
  task :update => :environment do
    require 'jdb_helper'
    require 'ttdb_helper'

    puts "Getting updates XML from ttdb"
    updatedata = TtdbHelper.get_updates_from_ttdb
    unless updatedata["Series"].nil?
      updatedata["Series"].each do |series|
        show_ttdbid = series['id'].first
        next if Tvshow.find_by_ttdb_show_id(show_ttdbid) == nil
        TtdbHelper.update_all_ttdb_data(show_ttdbid)
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

end
