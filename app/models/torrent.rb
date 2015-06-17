class Torrent < ActiveRecord::Base
  attr_accessible :completed, :hash_string, :name, :percent, :size, :status, :time_completed, :time_started
end
