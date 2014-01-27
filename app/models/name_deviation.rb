class NameDeviation < ActiveRecord::Base
  attr_accessible :enabled, :episode_number, :season_number, :tvshow_id, :tvshow_title, :type
  belongs_to :tvshows
end
