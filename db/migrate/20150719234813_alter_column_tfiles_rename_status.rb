class AlterColumnTfilesRenameStatus < ActiveRecord::Migration
  def up
    change_column :tfiles, :rename_status, :boolean
  end

  def down
    change_column :tfiles, :rename_status, :string
  end
end
