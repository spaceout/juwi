require 'xmlsimple'
require 're_namer'

desc "This is one sexy renamer"
task :rename => :environment do
  filebot_log = '/home/jemily/.filebot/history.xml'
  filebot_history = XmlSimple.xml_in(filebot_log)
  filebot_history['sequence'].each do |sequence|
    sequence['rename'].each do |rename|
      puts Renamer.rename(rename['from'])
    end
  end
end
