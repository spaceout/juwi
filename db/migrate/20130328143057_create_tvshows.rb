class CreateTvshows < ActiveRecord::Migration
  def change
    create_table :tvshows do |t|
      t.integer :ttdb_show_id
      t.string :xdb_show_location
      t.integer :xdb_show_id
      t.string :ttdb_show_title
      t.integer :tvr_show_id
      t.integer :tvr_latest_season_number
      t.integer :tvr_latest_episode_number
      t.string :tvr_latest_episode_title
      t.date :tvr_latest_episode_date
      t.integer :tvr_next_season_number
      t.integer :tvr_next_episode_number
      t.string :tvr_next_episode_title
      t.date :tvr_next_episode_date
      t.string :tvr_show_url
      t.date :tvr_show_started
      t.date :tvr_show_ended
      t.string :tvr_show_status
      t.string :ttdb_show_imdb_id
      t.text :ttdb_show_overview
      t.integer :ttdb_show_last_updated
      t.string :ttdb_show_banner
      t.string :ttdb_show_fanart
      t.string :ttdb_show_poster
      t.integer :ttdb_show_rating
      t.integer :ttdb_show_rating_count
      t.string :ttdb_show_network
      t.string :ttdb_show_status
      t.integer :ttdb_show_runtime
      t.timestamps
    end
  end
end
