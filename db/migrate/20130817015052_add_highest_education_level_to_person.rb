class AddHighestEducationLevelToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :highest_education_level_id, :integer
  end

  def self.down
    remove_column :people, :highest_education_level_id
  end
end
