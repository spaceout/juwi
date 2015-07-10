class CreateTfiles < ActiveRecord::Migration
  def change
    create_table :tfiles do |t|
      t.string :name
      t.integer :length
      t.integer :bytes_completed
      t.string :rename_status
      t.string :rename_data
      t.belongs_to :torrent

      t.timestamps
    end
    add_index :tfiles, :torrent_id
  end
end
