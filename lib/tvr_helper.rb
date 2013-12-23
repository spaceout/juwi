require 'curl_helper'

class TvrHelper
  def self.get_tvrage_data(showname)
    rage_show = showname.gsub(" ", "%20").gsub("&", "and")
    tvrage_data = CurlHelper.get_http_data("http://services.tvrage.com/tools/quickinfo.php?show=#{rage_show}")
    tvrage = Hash[*tvrage_data.gsub!("<pre>","").gsub!("\n","@").split("@")]
    return tvrage
  end

  def self.update_tvrage_data(ttdb_showid)
    current_show = Tvshow.find_by_ttdb_show_id(ttdb_showid)
    title = current_show.tvr_search_name
    puts "Updating TVR for: #{title}"
    tvragedata = TvrHelper.get_tvrage_data(title)
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
    #update tvr data
    current_show.update_attributes(
      :tvr_show_id => tvragedata['Show ID'],
      :tvr_latest_season_number => tvr_latest_season_number,
      :tvr_latest_episode_number => tvr_latest_episode_number,
      :tvr_latest_episode_title => tvr_latest_episode_title,
      :tvr_latest_episode_date => tvr_latest_episode_date,
      :tvr_next_season_number => tvr_next_season_number,
      :tvr_next_episode_number => tvr_next_episode_number,
      :tvr_next_episode_title => tvr_next_episode_title,
      :tvr_next_episode_date => tvr_next_episode_date,
      :tvr_show_url => tvragedata['Show URL'],
      :tvr_show_started => tvragedata['Started'],
      :tvr_show_ended => tvragedata['Ended'],
      :tvr_show_status => tvragedata['Status']
      )
  end
end

