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
      if torrent["downloadDir"] == Setting.get_value('finished_path')
        #process_torrent(torrent)
      end
    end
  end


  def process_torrent(dl_torrent)
    db_torrent = Torrent.find_by_hash_string(torrent["hashString"])
    if db_torrent.nil?
      if torrent["totalSize"] == 0
        torrent["name"] = "MAGNET LINK"
      Torrent.create(
        :completed => torrent["isDone"],
        :hash_string => torrent["hashString"],
        :name => torrent["name"],
        :percent => torrent["percentDone"],
        :size => torrent["totalSize"],
        :status => "Downloading",
        :time_started => Time.now
      )
    else
      if torrent["isDone"] == false
        db_torrent.update_attributes(
          :percent => torrent["percentDone"],
          :completed => torrent["isDone"],
        )
      end
    end
  end
end

=begin
    torrent = Torrent.create(hashString)
    torrent.update_attributes(
      :completed => torrent["isDone"],
      :hash_string => torrent["hashString"],
      :name => torrent[name],
      :percent => torrent[percentDone],
      :size => torrent[totalSize],
      :status => "Downloading",
      :time_started => Time.now
    )

    #check download dir is the correct one, ignore other torrents
      #search for hashString
      #if not found
        #New Torrent
        #insert ID, time_started, Name (if not null, remember about magnet links), PercentDone, totalSize, isfinished, downloadDir and hashString
      #if found
        #if isFinished is NOT true
        #update name if not null
        #update percentdone and isFinished

puts "id = #{torrent["id"]}"
puts "name = #{torrent["name"]}"
puts "percentDone = #{torrent["percentDone"]}"
puts "totalSize = #{torrent["totalSize"]}"
puts "isFinished = #{torrent["isFinished"]}"
puts "downloadDir = #{torrent["downloadDir"]}"
puts "hashString = #{torrent["hashString"]}"
=end
