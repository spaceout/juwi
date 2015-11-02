class AddThumbUrlAndThumbHeightAndThumbWidthToEpisode < ActiveRecord::Migration
  def change
    add_column :episodes, :thumb_url, :string
    add_column :episodes, :thumb_height, :integer
    add_column :episodes, :thumb_width, :integer
  end
end
