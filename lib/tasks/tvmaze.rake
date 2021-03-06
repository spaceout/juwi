namespace :tvmaze do
  desc "This populates JDB with the tvmaze IDs based on TTDB ID"
  task :get_ids => :environment do
    require 'tvmaze_helper'
    Tvshow.all.each do |tvshow|
      next unless tvshow.tvmaze_id.nil?
      tvmaze_id = TvmazeHelper.get_id(tvshow.ttdb_id)
      if tvmaze_id.nil?
        puts "No TV Maze ID found for #{tvshow.title}"
        next
      end
      puts "#{tvshow.title} - #{tvmaze_id}"
      tvshow.update_attributes(:tvmaze_id => tvmaze_id)
    end
  end

  desc "This updates tvmaze data for non cancelled/ended shows"
  task :update => :environment do
    require 'tvmaze_helper'
    Tvshow.all.each do |tvshow|
      next if ["Canceled/Ended", "Ended", "Canceled"].include?(tvshow.status)
      next if tvshow.tvmaze_id.nil?
      #Tvshow.update_tvmaze_data(tvshow.tvmaze_id)
      print "#{tvshow.title} - "
      tvm_show_status = TvmazeHelper.get_show_status(tvshow.tvmaze_id)
      tvm_nextaired_date = TvmazeHelper.get_next_episode(tvshow.tvmaze_id)
      puts "#{tvm_show_status} - #{tvm_nextaired_date}"
      tvshow.update_attributes(:status => tvm_show_status)
    end
  end

end
