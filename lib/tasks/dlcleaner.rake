require "pathname"
require "fileutils"
require "logger"
require 'file_manipulator'
require 'xmission_api'
require 'xbmc_api'

desc "Process rars zips and folders in download folder"
task :processDownloads => :environment do
  CONFIG = YAML.load_file(File.join(Rails.root,'/settings/settings.yml'))["config"]
  xmission = XmissionApi.new(:username => CONFIG["transmission_user"],:password => CONFIG["transmission_password"],:url => CONFIG["transmission_url"])
  XmissionApi.remove_finished_downloads(xmission)
  FileManipulator.process_finished_directory(CONFIG["base_path"], CONFIG["min_videosize"])
end
