require 'xmlsimple'
require 're_namer'
require 'fileutils'

desc "This is the real renamer"
task :rename => :environment do
  Renamer.process_dir(Setting.get_value("finished_path"), Setting.get_value("tvshow_base_path"))
end
