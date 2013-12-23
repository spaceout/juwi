# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Setting.create(:name => "xbmcdb", :value => "mysql://xbmc:xbmc@127.0.0.1/MyVideos75")
Setting.create(:name => "ttdb_api_key")
Setting.create(:name => "base_path")
Setting.create(:name => "tvshow_base_path")
Setting.create(:name => "min_videosize", :value => 60000000)
Setting.create(:name => "xbmc_hostname")
Setting.create(:name => "xbmc_port", :value => 9090)
Setting.create(:name => "transmission_url", :value => "http://127.0.0.1:9091/transmission/rpc")
Setting.create(:name => "transmission_user", :value => "transmission")
Setting.create(:name => "transmission_password", :value => "transmission")
Setting.create(:name => "rename_dir")
Setting.create(:name => "destination_dir")
Setting.create(:name => "log_file")
Setting.create(:name => "ttdb_last_scrape")
Setting.create(:name => "xdb_last_scrape")
Setting.create(:name => "last_xdb_show_id")
Setting.create(:name => "last_xdb_episode_id")
