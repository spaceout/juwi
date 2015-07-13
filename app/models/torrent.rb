class Torrent < ActiveRecord::Base
  has_many :tfiles, :dependent => :destroy
  serialize :files
  attr_accessible :completed, :hash_string, :name, :percent, :size, :status, :time_completed, :time_started, :files, :xmission_id, :rate_download, :eta, :rename_status

  require 'xmission_api'
  @xmission = XmissionApi.new(
    :username => Setting.get_value("transmission_user"),
    :password => Setting.get_value("transmission_password"),
    :url => Setting.get_value("transmission_url")
  )

  def self.xmission_poller
    if @xmission.is_online?
      current_torrents = @xmission.all
      cleanup_torrents
      #maybe do a find or initialize by to create/load tbe torrent object to be passed around (like a whore)
      current_torrents.each do |dl_torrent|
        #if the torrent download directory is set to the finished folder
        if dl_torrent["downloadDir"].chomp("/") == Setting.get_value('finished_path').chomp("/")
          #find or initialize a new torrent object
          db_torrent = Torrent.find_or_initialize_by_hash_string(dl_torrent["hashString"])
          #Send it for processing along with the xmission hash
          db_torrent.process_torrent(torrent)
        end
      end
    else
      puts "boooooo xmission is currently offline"
    end
  end

  #dl_torrent = xmission hash
  def process_torrent(dl_torrent)
    #create or load a torrent object by hashstring
    dl_torrent_size = dl_torrent["totalSize"]
    #if the torrent size is showing 0, its a magnet link
    if dl_torrent_size == 0
      dl_torrent["name"] = "MAG LINK #{dl_torrent["name"]}"
    end
    #if the download is showing complete and the db entry says its not, it just finished process it
    if dl_torrent["isFinished"]
      if !completed
        puts "Detected completed torrent, queing processing_completed"
        delay(:queue => 'renamer').process_completed_torrent
      end
    end
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
      :rate_download => dl_torrent["rateDownload"]
    )
    #lets update all the files as well
    dl_torrent["files"].each do |torrent_file|
      db_tfile = tfiles.find_or_initialize_by_name(torrent_file["name"])
      db_tfile.update_attributes(
        :name => torrent_file["name"],
        :length => torrent_file["length"],
        :bytes_completed => torrent_file["bytesCompleted"]
      )
    end
  end

  #current_torrents = array of all xmission hashes
  def self.cleanup_torrents
    current_torrents = @xmission.all
    hash_list = []
    #unless we were passed an empty array, create and array of the current xmission download hashes
    unless current_torrents.empty?
      current_torrents.each do |torrent|
        hash_list.push(torrent["hashString"])
      end
    end
    #0 and 9 do mean that it has been stopped (or lost)
    inactive_status_numbers = [0,9]
    #
    #when torrent is stopped but not complete and then removed from xmission you will have status = 0 but complete = false
    #NOT currently in xmission
    #Status is anything but
    #
    #returns all downloads the database THINKS are still active (NOT marked as 0 or 9)
    db_active_dls = Torrent.where("status NOT IN (?)", inactive_status_numbers)
    #unless there are no active dls
    unless db_active_dls.nil?
      db_active_dls.each do |db_dl|
        #unless the current active dls in xmission matches the hash string of the current database download entry
        unless hash_list.include?(db_dl.hash_string)
          #update the database download entry to be "lost in transmission" (9)
          db_dl.update_attributes(
            :status => 9,
            :xmission_id => nil
          )
        end
      end
    end
  end

  def process_completed_torrent
    require 're_namer'
    #update the time_completed for torrent object
    update_attributes(:time_completed => DateTime.now)
        #remove torrent from xmission by id
    @xmission.remove(xmission_id)
    #no files = nothing to rename set rename status to false
    if tfiles.count == 0
      puts "RENAME FAILURE"
      update_attributes(:rename_status => false)
      return
    end
    #go through each file in the completed torrent
    tfiles.each do |torrent_file|
      #check if it is a video file
      if torrent_file.is_video_file?
        #rename the video file and store the rename result
        result = Renamer.process_file(File.join(Setting.get_value("finished_path"), torrent_file.name))
        #stuff the result back in the tfile entry
        torrent_file.update_attributes(:rename_data => result)
        #if there are no successful entries, mark the torrent rename status as false
        if result[:success].nil?
          puts "RENAME FAILURE"
          update_attributes(:rename_status => false)
        #if there are no failure entries and the torrent has not been previously false, set it true
        elsif result[:failure].nil? && torrent.rename_status != false
          puts "RENAME SUCCESS"
          update_attributes(:rename_status => true)
          #
          #delete remaining files/folders from finished directory
          #
        end
      else
        #if its not a video file, mark rename_result as "SKIP"
        torrent_file.update_attributes(:rename_data => "SKIP")
      end
    end
  end

  def status_to_s
    case status
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
maybe add 'root folder' to Torrent object, makes it easier to clean up (File.rm torrent.root_folder)

Situations:
  Download starts while juwi is not running but finishes while it is running - should pick up the half downloaded file no problem
  Download starts AND finishes AND is removed from xmission while juwi is not running - gets the new file from xbmc database
  Download starts with juwi, but finishes when its not running - cleanup torrents should pick this up, mark it as lost in xmission

ETA CODE DEFINITIONS
Unknown   = -2
Complete  = -1

=end
