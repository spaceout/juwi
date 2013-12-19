namespace :ttdb do
  desc "This updates TTDB data for all shows"
  task :update => :environment do
    require 'jdb_helper'

    updatedata = TtdbHelper.get_updates_from_ttdb
    #Check if we have any of the shows in the ttdb update xml that are to be updated
    unless updatedata["Series"].nil?
      updatedata["Series"].each do |series|
        currentshow = Tvshow.where(:ttdb_show_id => series["id"])
        next if currentshow.empty?
        #puts currentshow.first.ttdb_show_title
        JdbHelper.update_show(currentshow.first.ttdb_show_title)
        #DataRunner.update_ttdb_show_data(series["id"].first)
      end
    end
    #Reset last update time
    Settings.set_value("ttdb_last_scrape", updatedata["time"])
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
