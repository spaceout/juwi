class AddLatestEpisodeAndNextEpisodeToTvshows < ActiveRecord::Migration
  def change
    add_column :tvshows, :latest_episode, :integer
    add_column :tvshows, :next_episode, :integer
  end
end
