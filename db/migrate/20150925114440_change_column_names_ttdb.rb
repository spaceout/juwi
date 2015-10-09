class ChangeColumnNamesTtdb < ActiveRecord::Migration
  def change
    rename_column :tvshows, :ttdb_show_imdb_id, :imdb_id
    rename_column :tvshows, :ttdb_show_overview, :overview
    rename_column :tvshows, :ttdb_show_last_updated, :ttdb_last_updated
    rename_column :tvshows, :ttdb_show_banner, :banner
    rename_column :tvshows, :ttdb_show_fanart, :fanart
    rename_column :tvshows, :ttdb_show_poster, :poster
    rename_column :tvshows, :ttdb_show_rating, :rating
    rename_column :tvshows, :ttdb_show_rating_count, :rating_count
    rename_column :tvshows, :ttdb_show_network, :network
    rename_column :tvshows, :ttdb_show_runtime, :runtime
    rename_column :tvshows, :ttdb_show_id, :ttdb_id
    rename_column :tvshows, :ttdb_show_title, :title
    rename_column :tvshows, :tvr_show_started, :first_aired
    rename_column :tvshows, :xdb_show_location, :location
    rename_column :tvshows, :jdb_clean_show_title, :clean_title
  end
end
