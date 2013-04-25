require 'curb'

class CurlHelper

  def self.get_http_data(url)
    body_data = ""
    curl = Curl::Easy.new
    curl.follow_location = true
    curl.url = url
    curl.on_body do |data|
      body_data << data
      data.size
    end
    curl.perform
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
