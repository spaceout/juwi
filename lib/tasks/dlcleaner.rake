require "pathname"
require "fileutils"
require "logger"
require 'file_manipulator'
require 'xmission_api'
require 'xbmc_api'

desc "Process rars zips and folders in download folder"
task :processDownloads => :environment do
  xmission = XmissionApi.new(:username => Setting.get_value("transmission_user"),:password => Setting.get_value("transmission_password"),:url => Setting.get_value("transmission_url"))
  XmissionApi.remove_finished_downloads(xmission, (Setting.get_value("finished_path")+"/"))
  FileManipulator.process_finished_directory(Setting.get_value("finished_path"), Setting.get_value("min_videosize"))
end
