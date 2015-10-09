class AddTvmazeIdToTvshows < ActiveRecord::Migration
  def change
    add_column :tvshows, :tvmaze_id, :integer
  end
end
