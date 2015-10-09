class CreateTorrents < ActiveRecord::Migration
  def change
    create_table :torrents do |t|
      t.string :hash_string
      t.datetime :time_started
      t.datetime :time_completed
      t.string :name
      t.integer :size
      t.string :status
      t.integer :percent
      t.boolean :completed

      t.timestamps
    end
  end
end
