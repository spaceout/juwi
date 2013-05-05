require 'xmlsimple'
desc "This synch up the rest of the episode info"
task :reNamer => :environment do
  match_count = 0
  total_shows = 0
  filebot_log = '/home/jemily/.filebot/history.xml'
  filebot_history = XmlSimple.xml_in(filebot_log)
  filebot_history['sequence'].each do |sequence|
    sequence['rename'].each do |rename|
      #puts rename['from']
      total_shows += 1
      match_data = /^(?:(.*?.\d{4}.?)|^(.*?)).s?(\d?\d)e?x?(\d\d)/i.match(rename['from'])
      if match_data[1] == nil
        dirty_show_name = match_data[2]
      elsif match_data[2] == nil
        dirty_show_name = match_data[1].gsub(/20\d\d/, '')
      end
      season_number = match_data[3].to_i
      episode_number =  match_data[4].to_i
      clean_show_name = dirty_show_name.gsub(/[\.\-\_\:]/, ' ').gsub("!", '').gsub("'", '').gsub(/(\(|\))/,'').gsub(/us/i, '').gsub("  ", " ").downcase.strip
      tvshow_match = false
      Tvshow.all.each do |tvshow|
        if tvshow.ttdb_show_title.gsub(/[\.\-\_\:]/, ' ').gsub("!", '').gsub("'", '').gsub(/\(us\)/i, '').gsub("  ", " ").gsub(/\(20\d\d\)/, '').downcase.strip == clean_show_name
          #puts "MATCHED SHOW #{tvshow.ttdb_show_title} "
          match_count += 1
          tvshow_match = true
          if tvshow.episodes.where("ttdb_season_number = ? AND ttdb_episode_number = ?", season_number, episode_number).first == nil
            puts rename['from']
            puts "*************NO MATCHED EPISODE**************"
          else
            #print " MATCHED EPISODE " + '%02d' % season_number + "e" + '%02d' % episode_number + " - "
            #puts tvshow.episodes.where("ttdb_season_number = ? AND ttdb_episode_number = ?", season_number, episode_number).first.ttdb_episode_title
          end
        end
      end
      if tvshow_match == false
        puts rename['from']
        puts clean_show_name
        puts "*************NO MATCHED TVSHOW*************"
      end
    end
  end
  percent = (match_count.to_f/total_shows.to_f) * 100
  puts "matched #{match_count} out of #{total_shows} I only missed #{total_shows - match_count} for a score of #{percent}%"
end
