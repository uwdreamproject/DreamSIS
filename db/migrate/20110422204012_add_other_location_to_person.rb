class AddOtherLocationToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :other_location_id, :integer
  end

  def self.down
    remove_column :people, :other_location_id
  end
end
