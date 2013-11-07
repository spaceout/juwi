#American Dad - Add one to the season
#CSI - add crime scene investigators


class Exceptions
  def self.process(clean_show_name)
    if clean_show_name == "csi"
      puts "Exception found! Show Name: #{clean_show_name}"
      exception_show_name = "csi crime scene investigation"
      return exception_show_name
    elsif clean_show_name == "agents of s h i e l d"
      puts "Exception found! Show Name: #{clean_show_name}"
      exception_show_name = "marvels agents of s h i e l d"
      return exception_show_name
    elsif clean_show_name == "american dad"
      puts "Exception Found! Show Name: #{clean_show_name}"
      exception_show_name = "blerm"
      return exception_show_name
    else
      return clean_show_name
    end
  end
end
