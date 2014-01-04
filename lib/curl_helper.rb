require 'curb'

class CurlHelper

  def self.get_http_data(url)
    attempts = Setting.get_value("http_retries").to_i
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
      puts "Failed downloading #{url} trying again"
      puts "ERROR DOWNLOADING #{url}" if attempts == 0
      retry if attempts > 0
    end
    return body_data
  end

  def self.download_http_data(url, savelocation)
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
        attempts -= 1
        puts "Failed downloading #{url} trying again"
        puts "ERROR DOWNLOADING #{url}" if attempts == 0
        retry if attempts > 0
      end
    end
  end

end
