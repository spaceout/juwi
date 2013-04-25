require 'httparty'
require 'json'
require "logger"

class XmissionApi
  attr_accessor :session_id
  attr_accessor :url
  attr_accessor :basic_auth
  attr_accessor :fields
  attr_accessor :debug_mode

  TORRENT_FIELDS = ["id","name","totalSize","isFinished","downloadDir"]

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

  def post(options)
    JSON::parse(http_post(options).body)
  end

  def http_post(options)
    post_options = {
      :body => options.to_json,
      :headers => {"x-transmission-session-id" => session_id},
      :basic_auth => basic_auth
    }
    response = HTTParty.post(url, post_options)
    if(response.code == 409)
      @log.info "Bad Session ID changing..."
      @session_id = response.headers["x-transmission-session-id"]
      @log.info "New Session ID: #{@session_id}"
      @log.info "Retrying Post"
      response = http_post(options)
    end
    response
  end
end
