class Episode < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :tvshow
  scope :missing, -> {where("xdb_id IS NULL AND season_num > ? AND episode_num > ? AND airdate < ?",0,0,Date.today)}

  def sync(xdb_episode_id)
    require 'xdb_helper'
    xep = XdbEpisodeHelper.new(xdb_episode_id)
    update_attributes(
      :xdb_id => xep.get_id,
      :filename => xep.get_filename
    )
  end

  def clear_sync
    update_attributes(
      :xdb_id => nil,
      :filename => nil
    )
  end

end
