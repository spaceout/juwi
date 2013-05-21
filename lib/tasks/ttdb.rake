namespace :ttdb do
desc "This updates TTDB data for all shows"
task :update => :environment do
  require 'data_runner'

  #Figure out how long since last update
  current_time = TtdbHelper.get_time_from_ttdb.to_i
  last_update = Settings.where(:name => "ttdb_last_scrape").first.value.to_i
  time_since_last_update = current_time - last_update

  #Get updates from ttdb
  if time_since_last_update < 86400
    puts "Doing Daily Update"
    update_interval = 1
  elsif time_since_last_update < 604800
    puts "Doing Weekly Update"
    update_interval = 2
  elsif time_since_last_update < 18144000
    puts "Doing Monthly Update"
    update_interval = 3
  end

  updatedata = TtdbHelper.get_updates_from_ttdb(Settings.where(:name => "ttdb_last_scrape").first.value, update_interval)

  #Check if we have any of the shows in the ttdb update xml that are to be updated
  unless updatedata["Series"].nil?
    updatedata["Series"].each do |series|
      next if Tvshow.where(:ttdb_show_id => series["id"]).empty?
      DataRunner.update_ttdb_show_data(series["id"].first)
    end
  end

  #check if we have any episodes in the ttdb update xml that are to be updated
  unless updatedata["Episode"].nil?
    updatedata["Episode"].each do |episode|
      next if Episode.where(:ttdb_episode_id => episode["id"]).empty?
      DataRunner.update_ttdb_episode_data(episode["id"].first)
    end
  end

  #Reset last update time
  Settings.where(:name => "ttdb_last_scrape").first.update_attributes(:value => updatedata["time"])
end


####GET ALL TTDB IMAGES####
desc "This will download all images for current tvshows"
task :getImages => :environment do
  require 'data_runner'
  Tvshow.all.each do |tvshow|
    next if File.exist?(File.join(Rails.root, "/public/images/", "#{tvshow.ttdb_show_id}_banner.jpg"))
    TtdbHelper.get_all_images(tvshow)
  end
end
end
