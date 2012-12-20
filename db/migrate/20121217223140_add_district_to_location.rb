class AddDistrictToLocation < ActiveRecord::Migration
  def self.up
    add_column :locations, :district, :string
  end

  def self.down
    remove_column :locations, :district
  end
end
