namespace :ttdb do
  require 'ttdb_helper'
  require 'ruby-progressbar'

  desc "This updates TTDB data for all shows"
  task :update => :environment do
    puts "Getting updates XML from ttdb"
    update_set = TtdbHelper.get_updates_from_ttdb
    puts "Updating #{update_set.count} Series"
    progressbar = ProgressBar.create(:title => "TTDB Update", :total => update_set.count)
    update_set.each do |ttdb_show_id|
      Tvshow.update_all_ttdb_data(ttdb_show_id)
      progressbar.increment
    end
    #progressbar.finish
    Setting.set_value("ttdb_last_scrape", TtdbHelper.get_time_from_ttdb)
  end

  desc "This will download all images for current tvshows"
  task :get_images => :environment do
    Tvshow.all.each do |tvshow|
      next if File.exist?(File.join(Rails.root, "/public/images/", "#{tvshow.ttdb_show_id}_banner.jpg"))
      TtdbHelper.get_all_images(tvshow)
    end
  end

  desc "This searches TTDB for showname and returns ttdb IDs"
  task :search, [:showname] => :environment do |t, args|
    showname = args[:showname] || 'none'
    puts TtdbHelper.search_ttdb(showname)
  end

end
