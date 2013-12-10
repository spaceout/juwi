require 'curl_helper'

class TvrHelper
  def self.get_tvrage_data(showname)
    rage_show = showname.gsub(" ", "%20").gsub("&", "and")
    tvrage_data = CurlHelper.get_http_data("http://services.tvrage.com/tools/quickinfo.php?show=#{rage_show}", 2)
    tvrage = Hash[*tvrage_data.gsub!("<pre>","").gsub!("\n","@").split("@")]
    return tvrage
  end

#make sure to pass a Tvshow object to this function, not a name
  def self.update_tvrage_data(tvshow, jdbid)
    currentshow = Tvshow.find(jdbid)
    print 'Updating TVR for: '
    print tvshow
    print ' Status: '
    sanitized_title = tvshow.split("(").first
    tvragedata = TvrHelper.get_tvrage_data(sanitized_title)
    #prepare tvr data
    tvr_show_id = tvragedata['Show ID']
    tvr_show_url = tvragedata['Show URL']
    tvr_show_started = tvragedata['Started']
    tvr_show_ended = tvragedata['Ended']
    tvr_show_status = tvragedata['Status']
    #Process latest/next tvrage episode info
    tvr_latest_episode = tvragedata['Latest Episode']
    if tvr_latest_episode != nil
      tvr_latest_episode.force_encoding("utf-8")
      tvr_latest_season_number = tvr_latest_episode.split("^").first.split("x")[0]
      tvr_latest_episode_number = tvr_latest_episode.split("^").first.split("x")[1]
      tvr_latest_episode_title = tvr_latest_episode.split("^")[1]
      tvr_latest_episode_date = tvr_latest_episode.split("^")[2]
    end
    tvr_next_episode = tvragedata['Next Episode']
    if tvr_next_episode != nil
      tvr_next_episode.force_encoding("utf-8")
      tvr_next_season_number = tvr_next_episode.split("^").first.split("x")[0]
      tvr_next_episode_number = tvr_next_episode.split("^").first.split("x")[1]
      tvr_next_episode_title = tvr_next_episode.split("^")[1]
      tvr_next_episode_date = tvr_next_episode.split("^")[2]
    end
    puts tvr_show_status
    #update tvr data
    if currentshow.update_attributes(
      :tvr_show_id => tvr_show_id,
      :tvr_latest_season_number => tvr_latest_season_number,
      :tvr_latest_episode_number => tvr_latest_episode_number,
      :tvr_latest_episode_title => tvr_latest_episode_title,
      :tvr_latest_episode_date => tvr_latest_episode_date,
      :tvr_next_season_number => tvr_next_season_number,
      :tvr_next_episode_number => tvr_next_episode_number,
      :tvr_next_episode_title => tvr_next_episode_title,
      :tvr_next_episode_date => tvr_next_episode_date,
      :tvr_show_url => tvr_show_url,
      :tvr_show_started => tvr_show_started,
      :tvr_show_ended => tvr_show_ended,
      :tvr_show_status => tvr_show_status
      )
    else
      puts "Error Updating record"
      puts tvshow.errors
    end
  end
end

