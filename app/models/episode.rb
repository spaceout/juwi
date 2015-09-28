class Episode < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :tvshow
  scope :missing, where("xdb_id IS NULL AND season_num IS NOT 0 AND episode_num IS NOT 0 AND airdate < ?",Date.today)
end
