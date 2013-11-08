class AddCleanShowNameToTvshows < ActiveRecord::Migration
  def change
    add_column :tvshows, :jdb_clean_show_title, :text
  end
end
