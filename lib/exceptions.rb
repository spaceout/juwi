#American Dad - Add one to the season
#CSI - add crime scene investigators
#Agents of Shield - add marvels to the name
#

class Exceptions
  def self.process(clean_show_name, season_number, episode_number)
    if clean_show_name == "agents of s h i e l d"
      clean_show_name = "marvels agents of s h i e l d"
      puts "Exception found! New show name: #{clean_show_name}"
    elsif clean_show_name == "dragons defenders of berk"
      clean_show_name = "dragons riders of berk"
      puts "Exception Found! New show name: #{clean_show_name}"
    elsif clean_show_name == "avengers assemble"
      clean_show_name = "marvels avengers assemble"
      puts "Exception Found! New show name: #{clean_show_name}"
    elsif clean_show_name == "transporter the series"
      clean_show_name = "transporter"
      puts "Exception Found! New show name: #{clean_show_name}"
    elsif clean_show_name == "daredevil"
      clean_show_name = "marvels daredevil"
      puts "Exception Found! New show name: #{clean_show_name}"
    elsif clean_show_name == "marvels avengers ultron revolution"
      clean_show_name = "marvels avengers assemble"
      puts "Exception Found! New show name: #{clean_show_name}"
    elsif clean_show_name == "treehouse masters"
      season_number+=1
      puts "Exception Found! New season number #{season_number}"
    end
    return clean_show_name,season_number,episode_number
  end
end
