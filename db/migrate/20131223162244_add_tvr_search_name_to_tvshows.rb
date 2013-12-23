class AddTvrSearchNameToTvshows < ActiveRecord::Migration
  def change
    add_column :tvshows, :tvr_search_name, :string
  end
end
