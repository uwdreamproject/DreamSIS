class AddFamilyIncomeLevelToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :family_income_level_id, :integer
  end

  def self.down
    remove_column :people, :family_income_level_id
  end
end
