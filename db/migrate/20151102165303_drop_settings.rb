class DropSettings < ActiveRecord::Migration
  def up
    drop_table :settings
  end

  def down
  end
end
