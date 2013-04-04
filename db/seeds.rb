# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Settings.create(:name => "ttdb_last_scrape")
Settings.create(:name => "xdb_last_scrape")
Settings.create(:name => "last_xdb_show_id")
Settings.create(:name => "last_xdb_episode_id")
