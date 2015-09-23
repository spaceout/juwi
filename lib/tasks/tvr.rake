namespace :tvr do
  desc "This updates tvrage data for non cancelled/ended shows"
  task :update => :environment do
    require 'ruby-progressbar'
    progressbar = ProgressBar.create(:title => "TVR Update", :total => Tvshow.all.count)
    Tvshow.all.each do |tvshow|
      progressbar.increment
      next if ["Canceled/Ended", "Ended", "Canceled"].include?(tvshow.status)
      Tvshow.update_tvrage_data(tvshow.ttdb_show_id)
    end
  end

  namespace :update do
    desc "This updates tvrage data for ALL shows"
    task :all => :environment do
      Tvshow.all.each do |tvshow|
        Tvshow.update_tvrage_data(tvshow.ttdb_show_id)
      end
    end
  end

end

