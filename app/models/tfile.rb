class Tfile < ActiveRecord::Base
  belongs_to :torrent
  attr_accessible :bytes_completed, :length, :name, :rename_data, :rename_status

  def is_video_file?(torrent_file)
    torrent_file_path = File.join(Setting.get_value("finished_path"), name)
    return false if File.directory?(torrent_file_path)
    video_extnames = Setting.get_value("video_extensions").split(',')
    return true if video_extnames.include?(File.extname(name)) && length >= Setting.get_value("min_videosize").to_i
  end

end
