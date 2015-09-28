class ChangeColumnNamesForEpisodes < ActiveRecord::Migration
  def change
    rename_column :episodes, :xdb_episode_id, :xdb_id
    rename_column :episodes, :xdb_episode_location, :filename
    rename_column :episodes, :ttdb_episode_title, :title
    rename_column :episodes, :ttdb_season_number, :season_num
    rename_column :episodes, :ttdb_episode_number, :episode_num
    rename_column :episodes, :ttdb_episode_id, :ttdb_id
    rename_column :episodes, :ttdb_episode_overview, :overview
    rename_column :episodes, :ttdb_episode_last_updated, :ttdb_last_updated
    rename_column :episodes, :ttdb_episode_airdate, :airdate
    rename_column :episodes, :ttdb_episode_rating, :rating
    rename_column :episodes, :ttdb_episode_rating_count, :rating_count
  end
end
