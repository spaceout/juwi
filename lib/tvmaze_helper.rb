#Base URL:  http://api.tvmaze.com
#Show Data: /lookup/shows?tvrage=:id or /lookup/shows?thetvdb=:id
require 'curl_helper'

class TvmazeHelper
  def self.get_id(ttdb_id)
    data = CurlHelper.get_http_data("http://api.tvmaze.com/lookup/shows?thetvdb=#{ttdb_id}")
    if data.empty?
      return nil
    else
      data = JSON.parse(data)
    end
    id = data["id"]
    return id
  end

  def self.get_show_status(tvm_id)
    data = JSON.parse(CurlHelper.get_http_data("http://api.tvmaze.com/shows/#{tvm_id}"))
    show_status = data["status"]
  end

  def self.get_next_episode(tvm_id)
    data = JSON.parse(CurlHelper.get_http_data("http://api.tvmaze.com/shows/#{tvm_id}?embed=nextepisode"))
    if data["_embedded"].nil?
      return "TBA"
    else
      return data["_embedded"]["nextepisode"]["airdate"]
    end
  end

end
