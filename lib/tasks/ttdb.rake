namespace :ttdb do
  require 'ttdb_helper'
  require 'ruby-progressbar'

  desc "This updates TTDB data for all non-ended shows"
  task :update => :environment do
    require 'ttdb_helper'
    require 'ruby-progressbar'
    progressbar = ProgressBar.create(:title => "Updating Data", :total => Tvshow.all.count)
    Tvshow.all.each do |tvshow|
      progressbar.increment
      next if tvshow.status == "Ended"
      tvshow.delay.update_show
    end
  end

  namespace :update do
    desc "Update all TTDB data for all shows"
    task :all => :environment do
      require 'ttdb_helper'
      require 'ruby-progressbar'
      progressbar = ProgressBar.create(:title => "Updating Data", :total => Tvshow.all.count)
      Tvshow.all.each do |tvshow|
        puts "updating ttdbdata for #{tvshow.title}"
        tvshow.delay.update_show
        progressbar.increment
      end
      Setting.set_value("ttdb_last_scrape", TtdbHelper.get_time_from_ttdb)
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
