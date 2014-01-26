require 'file_manipulator'
require 'xmission_api'

desc "Process rars zips and folders in download folder"
task :process_downloads => :environment do
  xmission = XmissionApi.new(:username => Setting.get_value("transmission_user"),:password => Setting.get_value("transmission_password"),:url => Setting.get_value("transmission_url"))
  xmission.remove_finished_downloads
  FileManipulator.process_finished_directory(Setting.get_value("finished_path"), Setting.get_value("min_videosize"))
end
