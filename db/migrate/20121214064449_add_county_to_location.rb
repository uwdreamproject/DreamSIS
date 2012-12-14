class AddCountyToLocation < ActiveRecord::Migration
  def self.up
    add_column :locations, :county, :string
  end

  def self.down
    remove_column :locations, :county
  end
end
