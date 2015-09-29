class AddNextEpisodeDateAndLatestEpisodeDateToTvshows < ActiveRecord::Migration
  def change
    add_column :tvshows, :next_episode_date, :date
    add_column :tvshows, :latest_episode_date, :date
  end
end
