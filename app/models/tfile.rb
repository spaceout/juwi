class Tfile < ActiveRecord::Base
  belongs_to :torrent
  attr_accessible :bytes_completed, :length, :name, :rename_data, :rename_status

  def process_completed_tfile(manual_name = name)
    require 're_namer'
    #check if it is a video file
    if is_video_file?
      #rename the video file and store the rename result
      result = Renamer.process_file(File.join(Setting.get_value("finished_path"), manual_name))
      #if there are no successful entries:
      #mark the torrent rename status as false
      #mark the tfile rename status as false
      #shove the rename data into the tfile
      if result[:success].nil?
        puts "RENAME FAILURE"
        update_attributes(
          :rename_status => false,
          :rename_data => result[:failure][:reason]
        )
      #if there are no failure entries
      #mark the tfile rename_status as true
      #shove the rename data into the tfile
      elsif result[:failure].nil?
        puts "RENAME SUCCESS #{result[:success][:new_name]}"
        update_attributes(
          :rename_status => true,
          :rename_data => result[:success][:new_name]
        )
      else
        #if its not success or failure, something happened, false it up
        torrent.update_attributes(:rename_status => false)
      end
    else
      #if its not a video file, mark rename_result as "SKIP"
      update_attributes(:rename_data => "SKIP")
    end
  end

  def is_video_file?
    torrent_file_path = File.join(Setting.get_value("finished_path"), name)
    return false if File.directory?(torrent_file_path)
    video_extnames = Setting.get_value("video_extensions").split(',')
    return true if video_extnames.include?(File.extname(name)) && length >= Setting.get_value("min_videosize").to_i
  end

  def rename_status_tag
    if rename_status == true
      return 'success'
    elsif rename_status == false
      return 'danger'
    else
      return nil
    end
  end

end
