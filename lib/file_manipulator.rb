require "pathname"
require "fileutils"

class FileManipulator

  def self.process_rars(incoming_folder)
    puts "Searching #{incoming_folder} for rar files"
    Dir.glob("#{FileManipulator.escape_glob(incoming_folder)}/**/*.rar").each do |rar_file|
      puts "Extracting RAR File: #{rar_file}"
      `unrar e \"#{rar_file}\" \"#{File.dirname(rar_file)}\"`
      if $? == 0
        puts "UNRAR of #{rar_file} Successful!"
      elsif $? != 0
        puts "UNRAR of #{rar_file} Failed"
        abort("FATAL Error unrarring #{rar_file}")
      end
    end
    puts "Completed rar processing on #{incoming_folder}"
  end

  def self.move_videos(incoming_folder, base_path, min_videosize)
    video_extensions = Setting.get_value("video_extension")
    puts "Begin processing #{incoming_folder} for video files"
    Dir.glob("#{FileManipulator.escape_glob(incoming_folder)}/**/*{#{video_extensions}}").each do |video_file|
      if File.size(video_file) > min_videosize
        puts "Moving #{video_file} to #{base_path}"
        FileUtils.mv(video_file, base_path)
      end
    end
  end

  def self.delete_folder(incoming_folder, min_videosize)
    video_extensions = Setting.get_value("video_extension")
    puts "Double Checking to make sure #{incoming_folder} is clean"
    Dir.glob("#{FileManipulator.escape_glob(incoming_folder)}/**/*{#{video_extensions}}").each do |video_file|
      if File.size(video_file) > min_videosize
        abort("FATAL ERROR #{incoming_folder} IS NOT EMPTY")
      end
    end
    puts "Deleting #{incoming_folder}"
    FileUtils.rm_rf(incoming_folder)
  end

  def self.list_dir(directory)
    file_list = []
    dir_list = Dir.glob("#{escape_glob(directory)}/*")
    dir_list.each do |file|
      file_list.push(file.split("/").last)
    end
    return file_list
  end

  def self.escape_glob(directory)
    return directory.gsub(/[\\\{\}\[\]\*\?]/) { |x| "\\"+x }
  end

  def self.process_finished_directory(base_path, min_videosize)
    puts "Procesing Directory"
    Dir.chdir(base_path)
    Dir.glob("*").each do |dir_entry|
      if File.directory?(dir_entry)
        FileManipulator.process_rars(dir_entry)
        FileManipulator.move_videos(dir_entry, base_path, min_videosize)
        FileManipulator.delete_folder(dir_entry, min_videosize)
      end
    end
    puts "Processing directory complete"
  end
end
