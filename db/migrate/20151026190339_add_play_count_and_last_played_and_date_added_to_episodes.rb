class AddPlayCountAndLastPlayedAndDateAddedToEpisodes < ActiveRecord::Migration
  def change
    add_column :episodes, :play_count, :integer
    add_column :episodes, :last_played, :datetime
    add_column :episodes, :date_added, :datetime
  end
end
