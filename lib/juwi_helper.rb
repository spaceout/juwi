require 'sequel'
require 'xmission_api'
class JuwiHelper

  @@xbmcdb = nil
  def self.with_xbmcdb
    @@xbmcdb = get_new_xbmcdb_connection if @@xbmcdb.nil?
    yield @@xbmcdb
    @@xbmcdb.disconnect
  end

  def self.get_new_xbmcdb_connection
    Sequel.connect(Settings.xbmcdb)
  end

  @@xmission = nil
  def self.with_xmission
    @@xmission = XmissionApi.new(
      :username => Settings.transmission_user,
      :password => Settings.transmission_password,
      :url => Settings.transmission_url
    ) if @@xmission.nil?
    return @@xmission
  end

end

