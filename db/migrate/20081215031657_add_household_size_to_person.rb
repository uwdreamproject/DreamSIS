class AddHouseholdSizeToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :household_size, :integer
  end

  def self.down
    remove_column :people, :household_size
  end
end
