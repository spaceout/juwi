class ChangeColumnNamesTvr < ActiveRecord::Migration
  def change
    rename_column :tvshows, :tvr_latest_season_number, :latest_season_number
    rename_column :tvshows, :tvr_latest_episode_number, :latest_episode_number
    rename_column :tvshows, :tvr_latest_episode_title, :latest_episode_title
    rename_column :tvshows, :tvr_latest_episode_date, :latest_episode_date
    rename_column :tvshows, :tvr_next_season_number, :next_season_number
    rename_column :tvshows, :tvr_next_episode_number, :next_episode_number
    rename_column :tvshows, :tvr_next_episode_title, :next_episode_title
    rename_column :tvshows, :tvr_next_episode_date, :next_episode_date
    rename_column :tvshows, :tvr_show_status, :status
    rename_column :tvshows, :tvr_show_ended, :end_date
  end
end
