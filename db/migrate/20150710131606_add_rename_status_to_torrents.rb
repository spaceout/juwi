class AddRenameStatusToTorrents < ActiveRecord::Migration
  def change
    add_column :torrents, :rename_status, :boolean
  end
end
