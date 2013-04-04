# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130402162010) do

  create_table "episodes", :force => true do |t|
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.integer  "tvshow_id"
    t.integer  "xdb_episode_id"
    t.string   "xdb_episode_location"
    t.integer  "xdb_show_id"
    t.string   "jdb_episode_title"
    t.integer  "jdb_season_number"
    t.integer  "jdb_episode_number"
    t.integer  "ttdb_episode_id"
    t.text     "ttdb_episode_overview"
    t.integer  "ttdb_last_updated"
    t.integer  "ttdb_series_id"
  end

  create_table "settings", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "name"
    t.string   "value"
  end

  create_table "tvshows", :force => true do |t|
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "jdb_ttdb_id"
    t.string   "xdb_show_location"
    t.integer  "xdb_show_id"
    t.string   "jdb_show_title"
    t.integer  "tvr_show_id"
    t.string   "tvr_latest_episode"
    t.string   "tvr_next_episode"
    t.string   "tvr_url"
    t.string   "tvr_started"
    t.string   "tvr_ended"
    t.string   "tvr_status"
    t.string   "ttdb_imdb_id"
    t.text     "ttdb_overview"
    t.integer  "ttdb_last_updated"
    t.string   "ttdb_banner"
    t.string   "ttdb_fanart"
    t.string   "ttdb_poster"
  end

end
