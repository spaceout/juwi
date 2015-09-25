class ChangeColumnNamesSomeMore < ActiveRecord::Migration
  def change
    rename_column :tvshows, :tvr_show_id, :tvr_id
    rename_column :tvshows, :xdb_show_id, :xdb_id
    rename_column :tvshows, :tvr_show_url, :tvr_url
  end
end
