class CreateTvshows < ActiveRecord::Migration
  def change
    create_table :tvshows do |t|

      t.timestamps
      t.integer :jdb_ttdb_id
      t.string :xdb_show_location
      t.integer :xdb_show_id
      t.string :jdb_show_title
      t.integer :tvr_show_id
      t.string :tvr_latest_episode
      t.string :tvr_next_episode
      t.string :tvr_url
      t.string :tvr_started
      t.string :tvr_ended
      t.string :tvr_status
      t.string :ttdb_imdb_id
      t.text :ttdb_overview
      t.integer :ttdb_last_updated
      t.string :ttdb_banner
      t.string :ttdb_fanart
      t.string :ttdb_poster
    end
  end
end
