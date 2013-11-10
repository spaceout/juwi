require 'xmlsimple'
require 're_namer'
require 'fileutils'

CONFIG = YAML.load_file(File.join(Rails.root,'/settings/settings.yml'))["config"]


desc "Test against filebot history"
task :renametest => :environment do
  filebot_log = '/home/jemily/.filebot/history.xml'
  filebot_history = XmlSimple.xml_in(filebot_log)
  filebot_history['sequence'].each do |sequence|
    sequence['rename'].each do |rename|
      puts Renamer.rename(rename['from'], 1)[0]
    end
  end
end

desc "This is the real renamer"
task :rename => :environment do
  rename_input_dir = CONFIG["renamedir"]
  rename_output_dir = CONFIG["destinationdir"]
  Renamer.process_dir(rename_input_dir, rename_output_dir)
end
