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
      if torrent["downloadDir"].chomp("/") == Setting.get_value('finished_path').chomp("/")
        process_torrent(torrent)
      end
    end
  end

  def self.process_torrent(dl_torrent)
    db_torrent = Torrent.find_or_initialize_by_hash_string(dl_torrent["hashString"])
    dl_torrent_size = dl_torrent["totalSize"]
    if dl_torrent_size == 0
      dl_torrent["name"] = "MAGNET LINK"
      db_torrent.update_attributes(:status => "Downloading Metadata")
    end
    if [nil,0].include?(db_torrent.size)
      if dl_torrent["totalSize"] != 0
        db_torrent.update_attributes(
        :status => "Downloading"
        )
      end
    end
    if dl_torrent["isFinished"]
      if !db_torrent.completed
        db_torrent.update_attributes(
        :time_completed => DateTime.now,
        :status => "Download Completed"
        )
      end
    end
    db_torrent.update_attributes(
      :completed => dl_torrent["isFinished"],
      :hash_string => dl_torrent["hashString"],
      :name => dl_torrent["name"],
      :percent => (dl_torrent["percentDone"] * 100),
      :size => dl_torrent["totalSize"],
      :files => dl_torrent["files"],
      :time_started => Time.at(dl_torrent["addedDate"]).utc.to_datetime,
    )
  end
end
