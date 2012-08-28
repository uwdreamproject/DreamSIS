class AddCoordinatesToLocation < ActiveRecord::Migration
  def self.up
    add_column :locations, :latitude, :float
    add_column :locations, :longitude, :float
    add_column :locations, :address, :string
  end

  def self.down
    remove_column :locations, :address
    remove_column :locations, :longitude
    remove_column :locations, :latitude
  end
end
