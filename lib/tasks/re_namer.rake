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
      match_data = /^((?:.+?)(?:.20[01][0-9].?)?).s?(\d{1,2})e?x?(\d\d)/i.match(rename['from'])
      dirty_show_name = match_data[1].gsub(/20\d\d/, '')
      season_number = match_data[2].to_i
      episode_number =  match_data[3].to_i
      clean_show_name = dirty_show_name.gsub(/[\.\-\_\:]/, ' ').gsub("!", '').gsub("'", '').gsub(/(\(|\))/,'').gsub(/\Wus/i, '').gsub("  ", " ").downcase.strip
      tvshow_match = false
      Tvshow.all.each do |tvshow|
        if tvshow.ttdb_show_title.gsub(/[\.\-\_\:]/, ' ').gsub("!", '').gsub("'", '').gsub(/\(us\)/i, '').gsub("  ", " ").gsub(/\(20\d\d\)/, '').downcase.strip == clean_show_name
          #puts "MATCHED SHOW #{tvshow.ttdb_show_title} "
          match_count += 1
          tvshow_match = true
          if tvshow.episodes.where("ttdb_season_number = ? AND ttdb_episode_number = ?", season_number, episode_number).first == nil
            puts "*************NO MATCHED EPISODE**************"
            puts rename['from']
            puts "#{clean_show_name} s#{season_number} e#{episode_number}"
          else
            #print " MATCHED EPISODE " + '%02d' % season_number + "e" + '%02d' % episode_number + " - "
            #puts tvshow.episodes.where("ttdb_season_number = ? AND ttdb_episode_number = ?", season_number, episode_number).first.ttdb_episode_title
          end
        end
      end
      if tvshow_match == false
        puts "*************NO MATCHED TVSHOW*************"
        puts rename['from']
        puts clean_show_name
      end
    end
  end
  percent = (match_count.to_f/total_shows.to_f) * 100
  puts "matched #{match_count} out of #{total_shows}, I only missed #{total_shows - match_count} for a score of #{percent}%"
end
