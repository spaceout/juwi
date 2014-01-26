require 'sequel'
class JuwiHelper

  @@xbmcdb = nil
  def self.with_xbmcdb
    @@xbmcdb = get_new_xbmcdb_connection if @@xbmcdb.nil?
    yield @@xbmcdb
    @@xbmcdb.disconnect
  end

  def self.get_new_xbmcdb_connection
    Sequel.connect(Setting.get_value("xbmcdb"))
  end

  @@xmission = nil
  def self.with_xmission
    @@xmission = XmissionApi.new(
      :username => Setting.get_value("transmission_user"),
      :password => Setting.get_value("transmission_password"),
      :url => Setting.get_value("transmission_url")
    ) if @@xmission.nil?
    return @@xmission
  end

end

