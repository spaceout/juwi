require 'curb'

class CurlHelper

  def self.get_http_data(url)
    attempts = Setting.get_value("http_retries").to_i
    #puts "Fetching: #{url}"
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
        puts "Failed downloading #{url} trying again"
        CurlHelper.get_http_data(url)
      elsif attempts == 0
        puts "ERROR DOWNLOADING #{url}"
        return false
      end
    end
    return body_data
  end

  def self.download_http_data(url, savelocation)
    #puts "Downloading: #{url}"
    attempts = Setting.get_value("http_retries").to_i
    curl = Curl::Easy.new
    curl.follow_location = true
    curl.url = url
    File.open(savelocation, 'wb') do|f|
      curl.on_body do |data| 
        f << data
        data.size
      end
      begin
        curl.perform
      rescue
        if attempts != 0
          puts "Failed downloading #{url} trying again"
          CurlHelper.get_http_data(url, savelocation)
        elsif attempts == 0
          puts "ERROR DOWNLOADING #{url}"
          return false
        end
      end
    end
  end

end
