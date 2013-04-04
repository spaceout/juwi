class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|

      t.timestamps
      t.string :name
      t.string :value

    end
  end
end
