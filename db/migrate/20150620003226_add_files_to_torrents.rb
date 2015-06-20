class AddFilesToTorrents < ActiveRecord::Migration
  def change
    add_column :torrents, :files, :text
  end
end
