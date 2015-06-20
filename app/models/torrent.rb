class Torrent < ActiveRecord::Base
  serialize :files
  attr_accessible :completed, :hash_string, :name, :percent, :size, :status, :time_completed, :time_started, :files

  def self.xmission_check
    require 'xmission_api'
    xmission = XmissionApi.new(
      :username => Setting.get_value("transmission_user"),
      :password => Setting.get_value("transmission_password"),
      :url => Setting.get_value("transmission_url")
    )
    current_torrents = xmission.all
    current_torrents.each do |torrent|
      if torrent["downloadDir"] == "#{Setting.get_value('finished_path')}/"
        process_torrent(torrent)
      end
    end
  end

  def self.process_torrent(dl_torrent)
    if dl_torrent["totalSize"] == 0
      dl_torrent["name"] = "MAGNET LINK"
    end
    db_torrent = Torrent.find_or_initialize_by_hash_string(dl_torrent["hashString"])
    if dl_torrent["isFinished"]
      if !db_torrent.completed
        db_torrent.update_attributes(
        :time_completed => Time.now,
        :status => "Completed"
        )
      end
    end
    db_torrent.update_attributes(
      :completed => dl_torrent["isFinished"],
      :hash_string => dl_torrent["hashString"],
      :name => dl_torrent["name"],
      :percent => dl_torrent["percentDone"] * 100,
      :size => dl_torrent["totalSize"],
      :time_started => dl_torrent["addedDate"],
      :files => dl_torrent["files"]
    )
  end
end
