require 'fileutils'
require 'jdb_helper'
require 'exceptions'
require 'scrubber'

class Renamer

  def self.process_file(filename, rename_output_dir)
    if File.directory?(filename)
      rename_result = {:failure=>{:old_name=>filename, :reason=>"This is a Directory, not a File"}}
      return rename_result
    end
    rename_result = Renamer.rename(File.basename(filename))
    puts rename_result
    #if the rename result is successful
    if rename_result[:failure].nil?
      clean_name = rename_result[:success][:new_name]
      overwrite_enable = rename_result[:success][:overwrite_enable]
      new_path = File.join(rename_output_dir, clean_name.split(" - ").first, "/")
      new_name = clean_name + File.extname(filename)
      destination = new_path + new_name
      #If the directory exists
      if File.directory?(new_path)
        #if the file already exists
        if File.file?(destination)
          #if overwrite is enabled
          if overwrite_enable == true
            #then go ahead and move it because its a repack
            File.unlink(destination)
            puts "Moving #{filename} to #{destination}"
            return rename_result
#            FileUtils.mv(filename, destination)
          #else if overwrite is NOT enabled
          else
            #then dont move it, because it already exists
            puts "Destination already exists #{destination}"
            rename_result = {:failure => rename_result[:success]}
            rename_result[:failure][:reason] = "destination file exists"
            return rename_result
          end
        #else if the file does NOT exist
        else
          #go ahead and move it
          puts "Moving #{filename} to #{destination}"
          return {:success => {:old_name => rename_result[:success][:old_name], :new_name => destination}}
#          FileUtils.mv(filename, destination)
        end
      #else if the show directory is not found
      else
        #fail out, might be a new show or renamed show
        puts "Destination directory #{new_path} not found"
        rename_result = {:failure => rename_result[:success]}
        rename_result[:failure][:reason] = "destination folder does not exist: #{new_path}"
        return rename_result
      end
    #else if the rename failed
    else
      puts "No match for #{filename}"
      return rename_result
    end
  end

  def self.rename(dirty_name, attempt = 1)
    if attempt == 2
      puts "second try"
    end
    match_data = /^((?:The.100)|(?:.+?)(?:.20[01][0-9].?)?).s?(\d{1,2})e?x?(\d\d)/i.match(dirty_name.gsub("720p", ""))
    #enable overwriting if it is a repack
    overwrite_enable = false
    if /repack|proper/i.match(dirty_name)
      puts "REPACK FOUND, OVERWRITE ENABLED"
      overwrite_enable = true
    end
    if match_data == nil
      return {:failure => {:old_name => dirty_name, :reason => "no match data"}}
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
            return {:failure => {:old_name => dirty_name, :reason => "episode not found"}}
          end
        else
          matched_episode_title = matched_episode.first.ttdb_episode_title.gsub(/[?"\/':]/,'').gsub('’','\'')
          if matched_episode_title == "TBA"
            puts "TBA FOUND!"
            if attempt == 1
              JdbHelper.update_show(tvshow.first.ttdb_show_title)
              Renamer.rename(dirty_name, 2)
            end
          end
        rename_to = matched_show_title  +  " - s" '%02d' % season_number + "e" + '%02d' % episode_number + " - " + matched_episode_title
        return {:success => {:old_name => dirty_name, :new_name => rename_to, :overwrite_enable => overwrite_enable}}
        end
      else
        puts "Show Not found #{clean_show_title}"
        return {:failure => {:old_name => dirty_name, :reason => "show not found", :show_title => clean_show_title}}
      end
    end
  end
end
