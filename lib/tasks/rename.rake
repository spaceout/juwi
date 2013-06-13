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
      puts Renamer.rename(rename['from'])
    end
  end
end

desc "This is the real renamer"
task :rename => :environment do
  rename_input_dir = CONFIG["renamedir"]
  rename_output_dir = CONFIG["destinationdir"]
  Dir.glob(File.join(rename_input_dir, "*")).each do |dir_entry|
    next if File.directory?(dir_entry)
    #puts "OLD: #{dir_entry}"
    clean_name = Renamer.rename(File.basename(dir_entry))
    if clean_name != "#"
      new_path = File.join(rename_output_dir, clean_name.split(" - ").first, "/")
      new_name = clean_name + File.extname(dir_entry)
      destination = new_path + new_name
      if File.directory?(new_path)
        #puts "NEW: #{destination}"
        if File.file?(destination)
          puts "Destination already exists #{destination}"
        else
          puts "Moving #{dir_entry} to #{destination}"
          FileUtils.mv(dir_entry, destination)
        end
      else
        puts "Destination directory #{new_path} not found"
      end
    else
      puts "No matching show for #{dir_entry}"
    end
  end
end
