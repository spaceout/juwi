namespace :ttdb do
  require 'ttdb_helper'
  require 'ruby-progressbar'

  desc "This updates TTDB data for all shows that have changed since last checkin with TTDB"
  task :update => :environment do
    puts "Getting updates XML from ttdb"
    update_set = TtdbHelper.get_updates_from_ttdb
    puts "Updating #{update_set.count} Series"
    progressbar = ProgressBar.create(:title => "TTDB Update", :total => update_set.count)
    update_set.each do |ttdb_id|
      show = Tvshow.find_by_ttdb_id(ttdb_id)
      show.update_show
      progressbar.increment
    end
    #progressbar.finish
    Setting.set_value("ttdb_last_scrape", TtdbHelper.get_time_from_ttdb)
  end

  namespace :update do
    desc "Update all TTDB data for all shows"
    task :all => :environment do
      Tvshow.all.each do |tvshow|
        puts "updating ttdbdata for #{tvshow.title}"
        tvshow.update_show
      end
    end
  end


  desc "This will download all images for current tvshows"
  task :get_images => :environment do
    Tvshow.all.each do |tvshow|
      next if File.exist?(File.join(Rails.root, "/public/images/", "#{tvshow.ttdb_id}_banner.jpg"))
      TtdbHelper.get_all_images(tvshow)
    end
  end

  desc "This searches TTDB for showname and returns ttdb IDs"
  task :search, [:showname] => :environment do |t, args|
    showname = args[:showname] || 'none'
    puts TtdbHelper.search_ttdb(showname)
  end

end
