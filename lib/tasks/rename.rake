require 'xmlsimple'
require 're_namer'
require 'fileutils'

desc "This is the real renamer"
task :rename => :environment do
  Renamer.process_dir(Settings.finished_path, Settings.tvshow_base_path)
end
