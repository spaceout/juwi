class Torrent < ActiveRecord::Base
  has_many :tfiles, :dependent => :destroy
  attr_accessible :completed, :hash_string, :name, :percent, :size, :status, :time_completed, :time_started, :xmission_id, :rate_download, :eta, :rename_status

  def self.xmission
    require 'xmission_api'
    @@xmission ||= XmissionApi.new(
      :username => Setting.get_value("transmission_user"),
      :password => Setting.get_value("transmission_password"),
      :url => Setting.get_value("transmission_url"))
  end

  def xmission
    Torrent.xmission
  end

  def self.xmission_poller
    if xmission.is_online?
      current_torrents = xmission.all
      current_torrents.each do |dl_torrent|
        #if the torrent download directory is set to the finished folder
        if dl_torrent["downloadDir"].chomp("/") == Setting.get_value('finished_path').chomp("/")
          #find or initialize a new torrent object
          db_torrent = Torrent.find_or_initialize_by_hash_string(dl_torrent["hashString"])
          #Send it for processing along with the xmission hash
          db_torrent.process_torrent(dl_torrent)
        end
      end
      #cleanup torrents no longer found in xmission, makes sure the DB is in good shape
      cleanup_torrents
    else
      puts "xmission is currently offline, poller skipped"
    end
  end

  def self.cleanup_torrents
    current_torrents = xmission.all
    hash_list = []
    #unless we were passed an empty array, create and array of the current xmission download hashStrings
    unless current_torrents.empty?
      current_torrents.each do |torrent|
        hash_list.push(torrent["hashString"])
      end
    end
    #an active db torrent is one that has an xmission_id
    db_active_dls = Torrent.where("xmission_id IS NOT NULL")
    #unless there are no active dls
    unless db_active_dls.nil?
      db_active_dls.each do |db_dl|
        #unless the current active dls in xmission matches the hash string of the current database download entry
        unless hash_list.include?(db_dl.hash_string)
          #update the database download entry to be lost (9) and nil out xmission_id
          db_dl.update_attributes(
            :status => 9,
            :xmission_id => nil,
            :eta => -2)
        end
      end
    end
  end

  #dl_torrent = xmission hash of torrent info
  def process_torrent(dl_torrent)
    #skip processing if completed and DJ rename has not run yet
    return if completed
    #update all items in the db torrent entry
    update_attributes(
      :completed => dl_torrent["isFinished"],
      :hash_string => dl_torrent["hashString"],
      :name => dl_torrent["name"],
      :percent => (dl_torrent["percentDone"] * 100),
      :size => dl_torrent["totalSize"],
      :time_started => Time.at(dl_torrent["addedDate"]).utc.to_datetime,
      :status => dl_torrent["status"],
      :eta => dl_torrent["eta"],
      :xmission_id => dl_torrent["id"],
      :rate_download => dl_torrent["rateDownload"])
    #lets update all the files as well
    dl_torrent["files"].each do |torrent_file|
      db_tfile = tfiles.find_or_initialize_by_name(torrent_file["name"])
      db_tfile.update_attributes(
        :name => torrent_file["name"],
        :length => torrent_file["length"],
        :bytes_completed => torrent_file["bytesCompleted"])
    end
    #if the download is showing complete and the db entry says its not, it just finished process it
    if dl_torrent["isFinished"]
      puts "Detected completed torrent, queing processing_completed"
      delay(:queue => 'renamer').process_completed_torrent
    end
  end

  def process_completed_torrent
    require 're_namer'
    require 'xbmc_api'
    require 'jdb_helper'
    #update the time_completed for torrent object remove xmission ID
    update_attributes(
      :time_completed => DateTime.now,
      :xmission_id => nil)
    xmission.remove(xmission_id)
    #go through each file in the completed torrent
    tfiles.each do |torrent_file|
      torrent_file.process_completed_tfile
    end
    #update the torrent rename status based on tfile status
    update_rename_status
    #check rename_status and if true, run cleanup
    if rename_status
      puts "Rename of torrent successful, initiating cleanup"
      cleanup_torrent_files
      XbmcApi.update_library
      JdbHelper.delay(run_at: 5.minutes.from_now).sync_xdb_to_jdb
    end
  end

  def cleanup_torrent_files
    if tfiles.count == 0
      puts "No files in the torrent? something is wrong here"
      return
    elsif tfiles.count == 1
      puts "Single File Torrent, nothing to cleanup"
      return
    else
      #create the full pathname from successful torrent rename
      base_dir = File.join(Setting.get_value("finished_path"), name)
      if base_dir == Setting.get_value("finished_path").chomp('/')
        puts "error, not deleting root download path"
        return
      else
        if File.directory?(base_dir)
          puts "Removing folder #{base_dir}"
          FileUtils.rm_r(base_dir)
        else
          puts "Not a folder, not removing"
        end
      end
    end
  end

  def update_rename_status
    update_attributes(:rename_status => nil)
    tfiles.each do |tfile|
      if tfile.rename_status == false
        update_attributes(:rename_status => false)
      elsif tfile.rename_status == true && rename_status != false
        update_attributes(:rename_status => true)
      end
    end
  end

  def status_to_s
    if status == 0
      if completed
        return "Completed"
      else
        return "Paused"
      end
    elsif status == 1
      return "Queued to Check"
    elsif status == 2
      return "Checking Files"
    elsif status == 3
      return "Queued to Download"
    elsif status == 4
      if size == 0
        return "Magnet Link"
      else
        return "Downloading"
      end
    elsif status == 5
      return "Queued to Seed"
    elsif status == 6
      return "Seeding"
    elsif status == 9
      return "Lost"
    else
      return "Unknown Status"
    end
  end

  def pretty_eta
    if eta == -2
      return "Unknown"
    elsif eta == -1
      if percent == 100
        return "Complete"
      else
        return "Unknown"
      end
    elsif eta == nil
      return "Unknown"
    else
      seconds = eta % 60
      minutes = (eta / 60) % 60
      hours = eta / (60 * 60)
      if eta < 59
        return "#{eta}s"
      elsif eta.between?(60,3599)
        return format("%02dm %02ds", minutes, seconds)
      else
        return format("%02dh %02dm %02ds", hours, minutes, seconds)
      end
    end
  end

end
