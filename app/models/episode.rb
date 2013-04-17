class Episode < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :tvshow
  scope :missing, where("xdb_episode_id IS NULL AND ttdb_season_number IS NOT 0 AND ttdb_episode_airdate <= ?",Date.yesterday)
end
