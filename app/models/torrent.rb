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
      remove_completed_torrents
    end
  end

  def self.process_torrent(dl_torrent)
    db_torrent = Torrent.find_or_initialize_by_hash_string(dl_torrent["hashString"])
    dl_torrent_size = dl_torrent["totalSize"]
    current_status = dl_torrent["status"]

    if dl_torrent_size == 0
      dl_torrent["name"] = "MAG LINK #{dl_torrent["name"]}"
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
            :status => 9,
            :xmission_id => nil
          )
        end
      end
    end
  end

  def self.is_xmission_online?
    matches = /http:\/\/(.+):(\d+)/.match(Setting.get_value("transmission_url"))
    host = matches[1]
    port = matches[2]
    begin
      Timeout::timeout(1) do
        begin
          socket_test = TCPSocket.new(host, port)
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

  def self.remove_completed_torrents
    require 'xmission_api'
    xmission = XmissionApi.new(
      :username => Setting.get_value("transmission_user"),
      :password => Setting.get_value("transmission_password"),
      :url => Setting.get_value("transmission_url")
    )
    torrents = Torrent.where("xmission_id IS NOT NULL")
    torrents.each do |torrent|
      if torrent.completed && torrent.status == 0
        xmission.remove(torrent.xmission_id, false)
        torrent.update_attributes(
          :xmission_id => nil
        )
      end
    end
  end

  def process_completed_torrent
    #no files = nothing to rename
    require 're_namer2'
    return if files.count == 0
    #go through each file in the completed torrent
    files.each do |torrent_file|
      #check if it is a video file
      if Torrent.is_video_file?(torrent_file)
        puts "processing dis shit #{torrent_file["name"]}"
        result = Renamer.process_file(File.join(Setting.get_value("finished_path"), torrent_file["name"]), "/")
        puts result
        #update the file hash to include new name
        #move onto the next file in da array
        #remember to delete the root folder when compreto
      else
        puts "NOPE"
      end
    end
  end

  def self.is_video_file?(torrent_file)
    torrent_file_path = File.join(Setting.get_value("finished_path"), torrent_file["name"])
    return false if File.directory?(torrent_file_path)
    video_extnames = Setting.get_value("video_extensions").split(',')
    return true if video_extnames.include?(File.extname(torrent_file["name"])) && torrent_file["length"] >= Setting.get_value("min_videosize").to_i
  end

  def self.torrent_status(status_num)
    case status_num
    when 0
      return "Stopped"
    when 1
      return "Queued to Check"
    when 2
      return "Checking Files"
    when 3
      return "Queued to Download"
    when 4
      return "Downloading"
    when 5
      return "Queued to Seed"
    when 6
      return "Seeding"
    when 9
      return "Lost in Transmission"
    else
      return "Unknown Status"
    end
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

require 're_namer2'
Torrent.all.each do |torrent|
  torrent.files.each do |torrent_file|
    if Torrent.is_video_file?(torrent_file)
      Renamer.process_file(torrent_file["name"], "/mnt/blah/blah/")
    end
  end
end
=end
