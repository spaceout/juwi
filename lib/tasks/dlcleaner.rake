require "pathname"
require "fileutils"
require "logger"
require 'file_manipulator'
require 'xmission_api'
require 'xbmc_api'

desc "This is jemuby minus renamer (for now)"
task :processDownloads => :environment do
  CONFIG = YAML.load_file(File.join(Rails.root,'/settings/settings.yml'))["config"]

  #Initialize Logger
  if CONFIG["logtofile"] == false
    log = Logger.new(STDOUT)
  elsif CONFIG["logtofile"] == true
    log = Logger.new(CONFIG["logfile"], 'weekly')
  end
  log.level = Logger::INFO
  log.datetime_format = "%Y-%m-%d %H:%M:%S"
  log.formatter = proc do |severity, datetime, progname, msg|
    "[#{datetime.strftime(log.datetime_format)}] #{severity}: #{msg}\n"
  end
  log.info "Script Initialized"

  #Transmission Processing
  processGo = false
  log.info "Transmission processing Started"
  xmission = XmissionApi.new(:username => CONFIG["transmission_user"],:password => CONFIG["transmission_password"],:url => CONFIG["transmission_url"],:logger => log)
  xmission.all.each do |download|
    if download["isFinished"] == true && download["downloadDir"] == CONFIG["base_path"] + "/"
      log.warn "Removing #{download["name"]} from Transmission"
      xmission.remove(download["id"])
      processGo = true
    end
  end
  log.info "Transmission processing Complete"

  #File Processing
  if processGo == true || CONFIG["runfrom_cli"] == true
    fm = FileManipulator.new(log)
    Dir.chdir(CONFIG["base_path"])
    Dir.glob("*").each do |dir_entry|
      if File.directory?(dir_entry)
        fm.process_rars(dir_entry)
        fm.move_videos(dir_entry, CONFIG["base_path"], CONFIG["min_videosize"])
        fm.delete_folder(dir_entry, CONFIG["min_videosize"])
      end
    end
    log.info "Script Completed successfully"
  end
end
