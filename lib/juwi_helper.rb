require 'sequel'
class JuwiHelper

  @@xbmcdb = nil
  def self.with_xbmcdb
    @@xbmcdb = get_new_xbmcdb_connection if @@xbmcdb.nil?
    yield @@xbmcdb
  end

  def self.get_new_xbmcdb_connection
    Sequel.connect(Setting.get_value("xbmcdb"))
  end

=begin
  def self.with_xbmcdb
    xbmcdb = Sequel.connect(Settings.get_value('xbmcdb'))
    yield xbmcdb
    xbmcdb.disconnect
  end
=end

end

