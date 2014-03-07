#American Dad - Add one to the season
#CSI - add crime scene investigators
#Agents of Shield - add marvels to the name
#

class Exceptions
  def self.process(clean_show_name, season_number, episode_number)
    if clean_show_name == "csi"
      clean_show_name = "csi crime scene investigation"
      puts "Exception found! New show name: #{clean_show_name}"
    elsif clean_show_name == "agents of s h i e l d"
      clean_show_name = "marvels agents of s h i e l d"
      puts "Exception found! New show name: #{clean_show_name}"
    elsif clean_show_name == "american dad"
      season_number += 1
      puts "Exception Found! Show name: #{clean_show_name} New season number: #{season_number}"
    elsif clean_show_name == "eastbound and down"
      clean_show_name = "eastbound & down"
      puts "Exception Found! New show name: #{clean_show_name}"
    elsif clean_show_name == "dragons defenders of berk"
      clean_show_name = "dragons riders of berk"
      puts "Exception Found! New show name: #{clean_show_name}"
    elsif clean_show_name == "marvels avengers assemble"
      clean_show_name = "avengers assemble"
      puts "Exception Found! New show name: #{clean_show_name}"
    end
    return clean_show_name,season_number,episode_number
  end
end
