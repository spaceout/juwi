require 'curb'

class CurlHelper

  def self.get_http_data(url,attempts)
    puts "Fetching: #{url}"
    body_data = ""
    curl = Curl::Easy.new
    curl.follow_location = true
    curl.url = url
    curl.on_body do |data|
      body_data << data
      data.size
    end
    begin
      curl.perform
    rescue
      if attempts != 0
        puts "Failed downling #{url} trying again"
        CurlHelper.get_http_data(url, attempts - 1)
      elsif attempts == 0
        puts "ERROR DOWNLOADING #{url}"
        return false
      end
    end
    return body_data
  end

  def self.download_http_data(url, savelocation)
    puts "Downloading: #{url}"
    curl = Curl::Easy.new
    curl.follow_location = true
    curl.url = url
    File.open(savelocation, 'wb') do|f|
      curl.on_body do |data| 
        f << data
        data.size
      end
      curl.perform
    end
  end

end
