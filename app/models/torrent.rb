class Torrent < ActiveRecord::Base
  attr_accessible :completed, :hash_string, :name, :percent, :size, :status, :time_completed, :time_started

  def self.xmission_check
    require 'xmission_api'
    xmission = XmissionApi.new(
      :username => Setting.get_value("transmission_user"),
      :password => Setting.get_value("transmission_password"),
      :url => Setting.get_value("transmission_url")
    )
    current_torrents = xmission.all
    current_torrents.each do |torrent|
      puts "id = #{torrent["id"]}"
      puts "name = #{torrent["name"]}"
      puts "percentDone = #{torrent["percentDone"]}"
      puts "totalSize = #{torrent["totalSize"]}"
      puts "isFinished = #{torrent["isFinished"]}"
      puts "downloadDir = #{torrent["downloadDir"]}"
      puts "hashString = #{torrent["hashString"]}"
    end
  end
end
