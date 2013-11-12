class Renamer

  def self.process_dir(rename_input_dir, rename_output_dir)
    require 'fileutils'
    output = []
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
            output.push("Destination already exists #{destination}")
            if overwrite_enable == true
              puts "OVERWRITE IS ENABLED REMOVING #{destination}"
              output.push("OVERWRITE IS ENABLED REMOVING #{destination}")
              File.unlink(destination)
              puts "REMOVED #{destination}"
              ouput.push("REMOVED #{destination}")
              puts "Moving #{dir_entry} to #{destination}"
              output.push("Moving #{dir_entry} to #{destination}")
              FileUtils.mv(dir_entry, destination)
            end
          else
            puts "Moving #{dir_entry} to #{destination}"
            output.push("Moving #{dir_entry} to #{destination}")
            FileUtils.mv(dir_entry, destination)
          end
        else
          puts "Destination directory #{new_path} not found"
          output.push("Destination directory #{new_path} not found")
        end
      else
        puts "No match for #{dir_entry}"
        ouput.push("No match for #{dir_entry}")
      end
    end
    return output
  end

  def self.rename(dirty_name, attempt)
    require 'jdb_helper'
    require 'exceptions'
    require 'scrubber'
    if attempt == 2
      puts "second try"
    end
    match_data = /^((?:.+?)(?:.20[01][0-9].?)?).s?(\d{1,2})e?x?(\d\d)/i.match(dirty_name)
    #enable overwriting if it is a repack
    overwrite_enable = false
    if /repack|proper/i.match(dirty_name)
      puts "REPACK FOUND, OVERWRITE ENABLED"
      overwrite_enable = true
    end
    if match_data == nil
      return "#"
    else
      dirty_show_title = match_data[1].gsub(/20\d\d/, '')
      season_number = match_data[2].to_i
      episode_number = match_data[3].to_i
      clean_show_title = Scrubber.clean_show_title2(dirty_show_title)
      clean_show_title,season_number,episode_number = Exceptions.process(clean_show_title, season_number, episode_number)
      tvshow = Tvshow.where("jdb_clean_show_title = ?", clean_show_title)
      if tvshow.empty? == false
        match_ttdb_id = tvshow.first.ttdb_show_id
        matched_show_title = tvshow.first.ttdb_show_title.gsub(":", '')
        matched_episode = Episode.where("ttdb_season_number = ? AND ttdb_episode_number = ? AND ttdb_show_id = ?", season_number, episode_number, match_ttdb_id).reload
        if matched_episode.empty?
          puts "No Matched Episode for: #{matched_show_title} - s#{season_number}e#{episode_number} checking ttdb"
          if attempt == 1
            JdbHelper.update_show(tvshow.first.ttdb_show_title)
            Renamer.rename(dirty_name, 2)
          elsif attempt == 2
            puts "No Episode Found for: #{matched_show_title} - s#{season_number}e#{episode_number}"
            return "#"
          end
        else
          matched_episode_title = matched_episode.first.ttdb_episode_title.gsub('/',' ').gsub('?','')
          #If on the first try the episode title is TBA, try to update_show that shit, otherwise name it TBA
          if matched_episode_title == "TBA"
            if attempt == 1
              JdbHelper.update_show(tvshow.first.ttdb_show_title)
              Renamer.rename(dirty_name, 2)
            end
          end
        rename_to = matched_show_title  +  " - s" '%02d' % season_number + "e" + '%02d' % episode_number + " - " + matched_episode_title
        return rename_to,overwrite_enable
        end
      else
        puts "Show Not found #{clean_show_title}"
        return "#"
      end
    end
  end
end
