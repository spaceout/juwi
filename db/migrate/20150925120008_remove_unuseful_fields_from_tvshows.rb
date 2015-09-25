class RemoveUnusefulFieldsFromTvshows < ActiveRecord::Migration
  def up
    remove_column :tvshows, :ttdb_show_status
    remove_column :tvshows, :tvr_search_name
  end

  def down
    add_column :tvshows, :tvr_search_name, :string
    add_column :tvshows, :ttdb_show_status, :string
  end
end
