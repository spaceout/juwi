class AddXmissionIdAndRateDownloadAndEtaToTorrents < ActiveRecord::Migration
  def change
    add_column :torrents, :xmission_id, :integer
    add_column :torrents, :rate_download, :integer
    add_column :torrents, :eta, :integer
  end
end
