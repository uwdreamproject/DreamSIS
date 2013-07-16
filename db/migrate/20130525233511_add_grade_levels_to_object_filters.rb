class AddGradeLevelsToObjectFilters < ActiveRecord::Migration
  def self.up
    add_column :object_filters, :earliest_grade_level_level, :integer
    add_column :object_filters, :latest_grade_level_level, :integer
  end

  def self.down
    remove_column :object_filters, :latest_grade_level_level
    remove_column :object_filters, :earliest_grade_level_level
  end
end