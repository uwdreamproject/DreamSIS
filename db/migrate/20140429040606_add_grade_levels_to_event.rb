class AddGradeLevelsToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :earliest_grade_level_level, :integer
    add_column :events, :latest_grade_level_level, :integer
  end

  def self.down
    remove_column :events, :latest_grade_level_level
    remove_column :events, :earliest_grade_level_level
  end
end
