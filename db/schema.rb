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

ActiveRecord::Schema.define(:version => 20150625172633) do

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0, :null => false
    t.integer  "attempts",   :default => 0, :null => false
    t.text     "handler",                   :null => false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "episodes", :force => true do |t|
    t.integer  "tvshow_id"
    t.integer  "xdb_episode_id"
    t.string   "xdb_episode_location"
    t.integer  "xdb_show_id"
    t.string   "ttdb_episode_title"
    t.integer  "ttdb_season_number"
    t.integer  "ttdb_episode_number"
    t.integer  "ttdb_episode_id"
    t.text     "ttdb_episode_overview"
    t.integer  "ttdb_episode_last_updated"
    t.integer  "ttdb_show_id"
    t.date     "ttdb_episode_airdate"
    t.string   "ttdb_episode_rating"
    t.integer  "ttdb_episode_rating_count"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.string   "state"
  end

  create_table "name_deviations", :force => true do |t|
    t.integer  "tvshow_id"
    t.integer  "season_number"
    t.integer  "episode_number"
    t.string   "tvshow_title"
    t.boolean  "enabled"
    t.string   "type"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "settings", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "name"
    t.string   "value"
    t.string   "notes"
  end

  create_table "torrents", :force => true do |t|
    t.string   "hash_string"
    t.datetime "time_started"
    t.datetime "time_completed"
    t.string   "name"
    t.integer  "size"
    t.integer  "status",         :limit => 255
    t.integer  "percent"
    t.boolean  "completed"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.text     "files"
    t.integer  "xmission_id"
    t.integer  "rate_download"
    t.integer  "eta"
  end

  create_table "tvshows", :force => true do |t|
    t.integer  "ttdb_show_id"
    t.string   "xdb_show_location"
    t.integer  "xdb_show_id"
    t.string   "ttdb_show_title"
    t.integer  "tvr_show_id"
    t.integer  "tvr_latest_season_number"
    t.integer  "tvr_latest_episode_number"
    t.string   "tvr_latest_episode_title"
    t.date     "tvr_latest_episode_date"
    t.integer  "tvr_next_season_number"
    t.integer  "tvr_next_episode_number"
    t.string   "tvr_next_episode_title"
    t.date     "tvr_next_episode_date"
    t.string   "tvr_show_url"
    t.date     "tvr_show_started"
    t.date     "tvr_show_ended"
    t.string   "tvr_show_status"
    t.string   "ttdb_show_imdb_id"
    t.text     "ttdb_show_overview"
    t.integer  "ttdb_show_last_updated"
    t.string   "ttdb_show_banner"
    t.string   "ttdb_show_fanart"
    t.string   "ttdb_show_poster"
    t.integer  "ttdb_show_rating"
    t.integer  "ttdb_show_rating_count"
    t.string   "ttdb_show_network"
    t.string   "ttdb_show_status"
    t.integer  "ttdb_show_runtime"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.text     "jdb_clean_show_title"
    t.string   "tvr_search_name"
  end

end
