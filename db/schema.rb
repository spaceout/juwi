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

ActiveRecord::Schema.define(:version => 20151102184343) do

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
    t.integer  "xdb_id"
    t.string   "filename"
    t.integer  "xdb_show_id"
    t.string   "title"
    t.integer  "season_num"
    t.integer  "episode_num"
    t.integer  "ttdb_id"
    t.text     "overview"
    t.integer  "ttdb_last_updated"
    t.integer  "ttdb_show_id"
    t.date     "airdate"
    t.string   "rating"
    t.integer  "rating_count"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "state"
    t.integer  "play_count"
    t.datetime "last_played"
    t.datetime "date_added"
    t.string   "thumb_url"
    t.integer  "thumb_height"
    t.integer  "thumb_width"
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

  create_table "tfiles", :force => true do |t|
    t.string   "name"
    t.integer  "length"
    t.integer  "bytes_completed"
    t.boolean  "rename_status"
    t.string   "rename_data"
    t.integer  "torrent_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "tfiles", ["torrent_id"], :name => "index_tfiles_on_torrent_id"

  create_table "torrents", :force => true do |t|
    t.string   "hash_string"
    t.datetime "time_started"
    t.datetime "time_completed"
    t.string   "name"
    t.integer  "size"
    t.integer  "status"
    t.integer  "percent"
    t.boolean  "completed"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "xmission_id"
    t.integer  "rate_download"
    t.integer  "eta"
    t.boolean  "rename_status"
  end

  create_table "tvshows", :force => true do |t|
    t.integer  "ttdb_id"
    t.string   "location"
    t.integer  "xdb_id"
    t.string   "title"
    t.integer  "tvr_id"
    t.string   "tvr_url"
    t.date     "first_aired"
    t.date     "end_date"
    t.string   "status"
    t.string   "imdb_id"
    t.text     "overview"
    t.integer  "ttdb_last_updated"
    t.string   "banner"
    t.string   "fanart"
    t.string   "poster"
    t.integer  "rating"
    t.integer  "rating_count"
    t.string   "network"
    t.integer  "runtime"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.text     "clean_title"
    t.integer  "tvmaze_id"
    t.integer  "latest_episode"
    t.integer  "next_episode"
    t.date     "next_episode_date"
    t.date     "latest_episode_date"
  end

end
