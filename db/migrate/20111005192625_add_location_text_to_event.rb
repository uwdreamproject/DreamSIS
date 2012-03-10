class AddLocationTextToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :location_text, :string
  end

  def self.down
    remove_column :events, :location_text
  end
end
