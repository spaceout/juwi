class Renamer

  def self.process_dir(rename_input_dir, rename_output_dir)
    require 'fileutils'
    rename_input_dir = CONFIG["renamedir"]
    rename_output_dir = CONFIG["destinationdir"]
    Dir.glob(File.join(rename_input_dir, "*")).each do |dir_entry|
      next if File.directory?(dir_entry)
      clean_name,overwrite_enable = Renamer.rename(File.basename(dir_entry), 1)
      if clean_name != "#"
        new_path = File.join(rename_output_dir, clean_name.split(" - ").first, "/")
        new_name = clean_name + File.extname(dir_entry)
        destination = new_path + new_name
        if File.directory?(new_path)
          if File.file?(destination)
            puts "Destination already exists #{destination}"
            if overwrite_enable == true
              puts "OVERWRITE IS ENABLED REMOVING #{destination}"
              File.unlink(destination)
              puts "REMOVED #{destination}"
              puts "Moving #{dir_entry} to #{destination}"
              FileUtils.mv(dir_entry, destination)
            end
          else
            puts "Moving #{dir_entry} to #{destination}"
            FileUtils.mv(dir_entry, destination)
          end
        else
          puts "Destination directory #{new_path} not found"
        end
      else
        puts "No match for #{dir_entry}"
      end
    end
  end

  def self.rename(dirty_name, attempt)
    require 'jdb_helper'
    require 'exceptions'
    if attempt == 2
      puts "second try"
    end
    match_data = /^((?:.+?)(?:.20[01][0-9].?)?).s?(\d{1,2})e?x?(\d\d)/i.match(dirty_name)
    #enable overwriting if it is a repack
    overwrite_enable = false
    if /repack/i.match(dirty_name)
      puts "REPACK FOUND, OVERWRITE ENABLED"
      overwrite_enable = true
    end
    if match_data == nil
      return "#"
    else
      dirty_show_title = match_data[1].gsub(/20\d\d/, '')
      season_number = match_data[2].to_i
      episode_number = match_data[3].to_i
      clean_show_name = dirty_show_title.gsub(/[\.\-\_\:]/, ' ').gsub("!", '').gsub("'", '').gsub(/(\(|\))/,'').gsub(/\Wus/i, '').gsub("  ", " ").downcase.strip
      show_match = false
      episode_match = false
      matched_show_title = nil
      matched_episode_title = nil
      clean_show_name,season_number,episode_number = Exceptions.process(clean_show_name, season_number, episode_number)
      #
      #
      #FIX CODE BELOW HERE TO USE THE NEW JDB_CLEAN_SHOW_TITLE
      #
      #
      Tvshow.all.each do |tvshow|
        if tvshow.ttdb_show_title.gsub(/[\.\-\_\:]/, ' ').gsub("!", '').gsub("'", '').gsub(/\(us\)/i, '').gsub("  ", " ").gsub(/\(20\d\d\)/, '').downcase.strip == clean_show_name
          show_match = true
          match_ttdb_id = tvshow.ttdb_show_id
          matched_show_title = tvshow.ttdb_show_title.gsub(":", '')
          matched_episode = Episode.where("ttdb_season_number = ? AND ttdb_episode_number = ? AND ttdb_show_id = ?", season_number, episode_number, match_ttdb_id)
          if matched_episode.empty?
            puts "No Matched Episode; checking ttdb"
            if attempt == 1
              JdbHelper.update_show(tvshow.ttdb_show_title)
              Renamer.rename(dirty_name, 2)
            end
          else
            episode_match = true
            matched_episode_title = matched_episode.first.ttdb_episode_title.gsub('/',' ').gsub('?','')
            #If on the first try the episode title is TBA, try to update_show that shit, otherwise name it TBA
            if matched_episode_title == "TBA"
              unless attempt == 2
              JdbHelper.update_show(clean_show_name)
              Episode.reload
              Renamer.rename(dirty_name, 2)
              end
            end
          end
        end
      end
      #
      #
      #END OF CODE FIX NEEDED
      #
      #
      if show_match == true && episode_match == true
        rename_to = matched_show_title  +  " - s" '%02d' % season_number + "e" + '%02d' % episode_number + " - " + matched_episode_title
        return rename_to,overwrite_enable
      elsif show_match == true && episode_match == false
        puts "No Episode Found for: #{matched_show_title} - s#{season_number}e#{episode_number}"
        return "#"
      elsif show_match == false
        puts "No Matched Show Title Found for: #{dirty_show_title} - #{clean_show_name}"
        return "#"
      end
    end
  end
end
