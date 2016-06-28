namespace :ttdb do
  require 'ttdb_helper'
  require 'ruby-progressbar'

  desc "This updates TTDB data for all non-ended shows"
  task :update => :environment do
    require 'ttdb_helper'
    Tvshow.all.each do |tvshow|
      next if tvshow.status == "Ended"
      tvshow.delay.update_show
    end
  end

  namespace :update do
    desc "Update all TTDB data for all shows"
    task :all => :environment do
      Tvshow.all.each do |tvshow|
        tvshow.delay.update_show
      end
    end
  end


  desc "This will download all images for current tvshows"
  task :get_images => :environment do
    Tvshow.all.each do |tvshow|
      puts "#{tvshow.title} - creating directories and getting show images"
      TtdbHelper.get_tvshow_images(tvshow)
      puts "  Queuing #{tvshow.episodes.count} episode thumb downloads"
      tvshow.episodes.each do |episode|
        TtdbHelper.delay(:queue => 'get_images').get_episode_thumb(episode)
      end
    end
  end

  desc "This searches TTDB for showname and returns ttdb IDs"
  task :search, [:showname] => :environment do |t, args|
    showname = args[:showname] || 'none'
    puts TtdbHelper.search_ttdb(showname)
  end

end
