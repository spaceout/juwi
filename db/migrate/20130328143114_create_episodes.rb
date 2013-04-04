class CreateEpisodes < ActiveRecord::Migration
  def change
    create_table :episodes do |t|

      t.timestamps
      t.integer :tvshow_id
      t.integer :xdb_episode_id
      t.string :xdb_episode_location
      t.integer :xdb_show_id
      t.string :jdb_episode_title
      t.integer :jdb_season_number
      t.integer :jdb_episode_number
      t.integer :ttdb_episode_id
      t.text :ttdb_episode_overview
      t.integer :ttdb_last_updated
      t.integer :ttdb_series_id
    end
  end
end
