class AddSingleParentHouseholdToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :single_parent_household, :boolean
  end

  def self.down
    remove_column :people, :single_parent_household
  end
end
