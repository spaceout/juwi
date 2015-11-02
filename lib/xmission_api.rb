require 'httparty'
require 'json'
require 'logger'

class XmissionApi
  attr_accessor :session_id
  attr_accessor :url
  attr_accessor :basic_auth
  attr_accessor :fields
  attr_accessor :debug_mode

  TORRENT_FIELDS = ["id","name","percentDone","totalSize","isFinished","downloadDir","hashString", "files", "rateDownload", "addedDate", "status", "eta"]

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
    response = post(:method => "torrent-get", :arguments => {:fields => fields})
    response["arguments"]["torrents"]
  end

  def find(id)
    @log.info "Get Torrent Info for  #{id}"
    response = post(:method => "torrent-get", :arguments => {:fields => fields,:ids => [id]})
    response["arguments"]["torrents"].first
  end

  def remove(id, delete_local_data=false)
    @log.info "Remove Torrent: #{id} Delete Local Data: #{delete_local_data}"
    response = post(:method => "torrent-remove", :arguments => {:ids => [id], :'delete-local-data'=> delete_local_data})
    response
  end

  def stop(id)
    @log.info "Pausing Torrent: #{id}"
    response = post(:method => "torrent-stop", :arguments => {:ids => [id]})
    response
  end

  def start(id)
    @log.info "Starting Torrent: #{id}"
    response = post(:method => "torrent-start", :arguments => {:ids => [id]})
    response
  end

  def upload_link(url, destination)
    @log.info "Uploading: #{url}"
    response = post(:method => "torrent-add",:arguments => {:filename => url, :'download-dir' => "#{Settings.finished_path}/"})
    response
  end

  def post(options)
    JSON::parse(http_post(options).body)
  end

  def http_post(options)
    post_options = {
      :body => options.to_json,
      :headers => {"x-transmission-session-id" => Settings.xmission_token},
      :basic_auth => basic_auth
    }
    response = HTTParty.post(url, post_options)
    if(response.code == 409)
      @log.info "Bad Session ID changing..."
      Setting.xmission_token = response.headers["x-transmission-session-id"])
      @log.info "New Session ID: #{Settings.xmission_token)}"
      @log.info "Retrying Post"
      response = http_post(options)
    end
    response
  end

  def remove_finished_downloads
    @log.info "Removing finished downloads from transmission"
    all.each do |download|
      if download["isFinished"] == true && download["downloadDir"].chomp("/") == Settings.finished_path
        @log.info "Removing #{download["name"]} from Transmission"
        remove(download["id"])
      end
    end
    @log.info "Done with removing finished downloads from transmission"
  end

  def is_online?
    matches = /http:\/\/(.+):(\d+)/.match(url)
    host = matches[1]
    port = matches[2]
    begin
      Timeout::timeout(1) do
        begin
          socket_test = TCPSocket.new(host, port)
          socket_test.close
          return true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          return false
        end
      end
    rescue Timeout::Error
    end
    return false
  end

end

=begin

STATUS CODE DEFINITIONS
TR_STATUS_STOPPED        = 0, /* Torrent is stopped */
TR_STATUS_CHECK_WAIT     = 1, /* Queued to check files */
TR_STATUS_CHECK          = 2, /* Checking files */
TR_STATUS_DOWNLOAD_WAIT  = 3, /* Queued to download */
TR_STATUS_DOWNLOAD       = 4, /* Downloading */
TR_STATUS_SEED_WAIT      = 5, /* Queued to seed */
TR_STATUS_SEED           = 6  /* Seeding */

ETA CODE DEFINITIONS
Unknown   = -2
Complete  = -1

=end
