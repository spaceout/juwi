class RemoveFilesFromTorrent < ActiveRecord::Migration
  def up
    remove_column :torrents, :files
  end

  def down
    add_column :torrents, :files, :string
  end
end
