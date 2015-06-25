class ChangeTypeStatusInTorrents < ActiveRecord::Migration
  def up
    change_column :torrents, :status, :integer
  end

  def down
    change_column :torrents, :status, :string
  end
end
