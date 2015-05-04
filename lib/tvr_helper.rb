require 'curl_helper'

class TvrHelper
  def self.get_tvrage_data(showname)
    rage_show = showname.gsub(" ", "%20").gsub("&", "and")
    tvrage_data = CurlHelper.get_http_data("http://services.tvrage.com/tools/quickinfo.php?show=#{rage_show}")
    begin
      tvrage = Hash[*tvrage_data.gsub!("<pre>","").gsub!("\n","@").split("@")]
    rescue
      puts "Error occured processing data from TVRage for #{showname}: Skipping"
    end
    return tvrage
  end

end

