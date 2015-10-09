class RemoveLatestSeasonNumberAndLatestEpisodeNumberAndLatestEpisodeTitleAndLatestEpisodeDateFromTvshows < ActiveRecord::Migration
  def up
    remove_column :tvshows, :latest_season_number
    remove_column :tvshows, :latest_episode_number
    remove_column :tvshows, :latest_episode_title
    remove_column :tvshows, :latest_episode_date
    remove_column :tvshows, :next_season_number
    remove_column :tvshows, :next_episode_number
    remove_column :tvshows, :next_episode_title
    remove_column :tvshows, :next_episode_date
  end

  def down
    add_column :tvshows, :latest_episode_date, :date
    add_column :tvshows, :latest_episode_title, :string
    add_column :tvshows, :latest_episode_number, :integer
    add_column :tvshows, :latest_season_number, :integer
    add_column :tvshows, :next_season_number, :integer
    add_column :tvshows, :next_episode_number, :integer
    add_column :tvshows, :next_episode_title, :integer
    add_column :tvshows, :next_episode_date, :date
  end
end
