class Episode < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :tvshow
end
