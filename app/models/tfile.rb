class Tfile < ActiveRecord::Base
  belongs_to :torrent
  attr_accessible :bytes_completed, :length, :name, :rename_data, :rename_status

  def process_completed_tfile(manual_name = name, overwrite = false)
    require 're_namer'
    require 'xbmc_api'
    require 'jdb_helper'
    #check if it is a video file
    if is_video_file?
      #rename the video file and store the rename result
      result = Renamer.process_file(File.join(Settings.finished_path, name), manual_name, overwrite)
      #if there are no successful entries (failure)
      if result[:success].nil?
        puts "RENAME FAILURE"
        update_attributes(
          :rename_status => false,
          :rename_data => result[:failure][:reason])
      #if there are no failure entries (success)
      elsif result[:failure].nil?
        puts "RENAME SUCCESS #{result[:success][:new_name]}"
        update_attributes(
          :rename_status => true,
          :rename_data => result[:success][:new_name]
        )
        XbmcApi.update_library
        JdbHelper.delay(run_at: 5.minutes.from_now).sync_xdb_to_jdb
      end
    else
      #if its not a video file, mark rename_result as "SKIP"
      update_attributes(:rename_data => "SKIP")
    end
  end

  def is_video_file?
    torrent_file_path = File.join(Settings.finished_path, name)
    return false if File.directory?(torrent_file_path)
    video_extnames = Settings.video_extensions.split(',')
    return true if video_extnames.include?(File.extname(name)) && length >= Settings.min_videosize.to_i
  end

end
