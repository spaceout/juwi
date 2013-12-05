# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Settings.create(:name => "xbmcdb", :value => "mysql://xbmc:xbmc@127.0.0.1/MyVideos75")
Settings.create(:name => "ttdb_api_key")
Settings.create(:name => "base_path")
Settings.create(:name => "tvshow_base_path")
Settings.create(:name => "min_videosize", :value => 60000000)
Settings.create(:name => "xbmc_hostname")
Settings.create(:name => "xbmc_port", :value => 9090)
Settings.create(:name => "transmission_url", :value => "http://127.0.0.1:9091/transmission/rpc")
Settings.create(:name => "transmission_user", :value => "transmission")
Settings.create(:name => "transmission_password", :value => "transmission")
Settings.create(:name => "rename_dir")
Settings.create(:name => "destination_dir")
Settings.create(:name => "log_file")
Settings.create(:name => "ttdb_last_scrape")
Settings.create(:name => "xdb_last_scrape")
Settings.create(:name => "last_xdb_show_id")
Settings.create(:name => "last_xdb_episode_id")
