class Torrent < ActiveRecord::Base
  serialize :files
  attr_accessible :completed, :hash_string, :name, :percent, :size, :status, :time_completed, :time_started, :files, :xmission_id, :rate_download, :eta

  def self.xmission_check
    if is_xmission_online?
      require 'xmission_api'
      xmission = XmissionApi.new(
        :username => Setting.get_value("transmission_user"),
        :password => Setting.get_value("transmission_password"),
        :url => Setting.get_value("transmission_url")
      )
      current_torrents = xmission.all
      cleanup_torrents(current_torrents)
      current_torrents.each do |torrent|
        if torrent["downloadDir"].chomp("/") == Setting.get_value('finished_path').chomp("/")
          process_torrent(torrent)
        end
      end
    end
  end

  def self.process_torrent(dl_torrent)
    db_torrent = Torrent.find_or_initialize_by_hash_string(dl_torrent["hashString"])
    dl_torrent_size = dl_torrent["totalSize"]
    current_status = dl_torrent["status"]

    if dl_torrent_size == 0
      dl_torrent["name"] = "MAGNET LINK"
    end

    if dl_torrent["isFinished"]
      if !db_torrent.completed
        db_torrent.update_attributes(
          :time_completed => DateTime.now,
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
      :status => dl_torrent["status"],
      :eta => dl_torrent["eta"],
      :xmission_id => dl_torrent["id"],
      :rate_download => dl_torrent["rateDownload"]
    )
  end

  def self.cleanup_torrents(current_torrents)
    puts "its cleanup time"
    hash_list = []
    unless current_torrents.empty?
      current_torrents.each do |torrent|
        hash_list.push(torrent["hashString"])
      end
    end
    inactive_status_numbers = [0,9]
    active_dls = Torrent.where("status NOT IN (?)", inactive_status_numbers)
    unless active_dls.nil?
      active_dls.each do |dl|
        unless hash_list.include?(dl.hash_string)
          dl.update_attributes(
            :status => 9
          )
        end
      end
    end
  end

  def self.is_xmission_online?
    matches = /(\b(?:\d{1,3}\.){3}\d{1,3}\b)\:(\d\d\d\d)/.match(Setting.get_value("transmission_url"))
    ip = matches[1]
    port = matches[2]
    begin
      Timeout::timeout(1) do
        begin
          socket_test = TCPSocket.new(ip, port)
          socket_test.close
          return true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          return false
        end
      end
    rescue Timeout::Error
    end
    return false
  end
end



=begin

STATUS CODE DEFINITIONS
TR_STATUS_STOPPED        = 0, /* Torrent is stopped */
TR_STATUS_CHECK_WAIT     = 1, /* Queued to check files */
TR_STATUS_CHECK          = 2, /* Checking files */
TR_STATUS_DOWNLOAD_WAIT  = 3, /* Queued to download */
TR_STATUS_DOWNLOAD       = 4, /* Downloading */
TR_STATUS_SEED_WAIT      = 5, /* Queued to seed */
TR_STATUS_SEED           = 6  /* Seeding */
juwi lost in xmission    = 9  Removed from xmission directly

ETA CODE DEFINITIONS
Unknown   = -2
Complete  = -1

=end
