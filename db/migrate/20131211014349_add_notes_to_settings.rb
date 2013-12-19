class AddNotesToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :notes, :string
  end
end
