class CreateNameDeviations < ActiveRecord::Migration
  def change
    create_table :name_deviations do |t|
      t.integer :tvshow_id
      t.integer :season_number
      t.integer :episode_number
      t.string :tvshow_title
      t.boolean :enabled
      t.string :type

      t.timestamps
    end
  end
end
