require 'xmlsimple'
desc "This synch up the rest of the episode info"
task :reNamer => :environment do
  filebot_log = '/home/jemily/.filebot/history.xml'
  filebot_history = XmlSimple.xml_in(filebot_log)
  filebot_history['sequence'].each do |sequence|
    sequence['rename'].each do |rename|
      puts rename['from']
      match_data = /^(?:(.*?.\d{4}.?)|^(.*?)).s?(\d?\d)e?x?(\d\d)/i.match(rename['from'])
      if match_data[1] == nil
        dirty_show_name = match_data[2]
      elsif match_data[2] == nil
        dirty_show_name = match_data[1]
      end
      season_number = match_data[3].to_i
      episode_number =  match_data[4].to_i
      clean_show_name = dirty_show_name.gsub(/[\.\-\_]/, ' ').gsub(/[\(\)\']/, '').downcase.strip
      #puts clean_show_name + " - s" + '%02d' % season_number + "e" + '%02d' % episode_number
      Tvshow.all.each do |tvshow|
        if tvshow.ttdb_show_title.gsub(/[\.\-\_]/, ' ').gsub(/[\(\)\']/, '').downcase.strip == clean_show_name
          print "MATCHED #{tvshow.ttdb_show_title} "
          print " - s" + '%02d' % season_number + "e" + '%02d' % episode_number + " - "
          puts tvshow.episodes.where("ttdb_season_number = ? AND ttdb_episode_number = ?", season_number, episode_number).first.ttdb_episode_title
          
        end
      end
      #xbmcshowid = Tvshow.where("ttdb_show_title = ?", clean_show_name).first.ttdb_show_title
    end
  end
end
