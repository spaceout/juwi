require 'httparty'
require 'json'
require "logger"

class XmissionApi
  attr_accessor :session_id
  attr_accessor :url
  attr_accessor :basic_auth
  attr_accessor :fields
  attr_accessor :debug_mode

  TORRENT_FIELDS = ["id","name","percentDone","totalSize","isFinished","downloadDir","hashString"]

  def initialize(options)
    @url = options[:url]
    @fields = options[:fields] || TORRENT_FIELDS
    @basic_auth = {:username => options[:username], :password => options[:password]}
    @session_id = "NoSessionIDYet"
    @debug_mode = options[:debug_mode] || false
    @log = options[:logger] || Logger.new(STDOUT)
  end

  def all
    @log.info "Get All Downloads"
    response = post(:method => "torrent-get",:arguments => {:fields => fields})
    response["arguments"]["torrents"]
  end

  def find(id)
    @log.info "Get Torrent Info for  #{id}"
    response = post(:method => "torrent-get",:arguments => {:fields => fields,:ids => [id]})
    response["arguments"]["torrents"].first
  end

  def remove(id)
    @log.info "Remove Torrent: #{id}"
    response = post(:method => "torrent-remove",:arguments => {:ids => [id]})
    response
  end

  def upload_link(url, destination)
    puts "Uploading: #{url}"
    response = post(:method => "torrent-add",:arguments => {:filename => url, :'download-dir' => "#{Setting.get_value("finished_path")}/"})
    response
  end

  def post(options)
    JSON::parse(http_post(options).body)
  end

  def http_post(options)
    post_options = {
      :body => options.to_json,
      :headers => {"x-transmission-session-id" => Setting.get_value("xmission_token")},
      :basic_auth => basic_auth
    }
    response = HTTParty.post(url, post_options)
    if(response.code == 409)
      @log.info "Bad Session ID changing..."
      Setting.set_value("xmission_token", response.headers["x-transmission-session-id"])
      @log.info "New Session ID: #{Setting.get_value("xmission_token")}"
      @log.info "Retrying Post"
      response = http_post(options)
    end
    response
  end

  def remove_finished_downloads
    puts "Removing finished downloads from transmission"
    all.each do |download|
      if download["isFinished"] == true && download["downloadDir"] == Setting.get_value("finished_path") + "/"
        puts "Removing #{download["name"]} from Transmission"
        remove(download["id"])
      end
    end
    puts "Done with removing finished downloads from transmission"
  end

end
