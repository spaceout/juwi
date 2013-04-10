class CreateEpisodes < ActiveRecord::Migration
  def change
    create_table :episodes do |t|

      t.integer :tvshow_id
      t.integer :xdb_episode_id
      t.string :xdb_episode_location
      t.integer :xdb_show_id
      t.string :ttdb_episode_title
      t.integer :ttdb_season_number
      t.integer :ttdb_episode_number
      t.integer :ttdb_episode_id
      t.text :ttdb_episode_overview
      t.integer :ttdb_episode_last_updated
      t.integer :ttdb_show_id
      t.date :ttdb_episode_airdate
      t.string :ttdb_episode_rating
      t.integer :ttdb_episode_rating_count
      t.timestamps
    end
  end
end
