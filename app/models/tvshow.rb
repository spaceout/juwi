class Tvshow < ActiveRecord::Base
  # attr_accessible :title, :body
  #
  has_many :episodes, :dependent => :destroy
end
