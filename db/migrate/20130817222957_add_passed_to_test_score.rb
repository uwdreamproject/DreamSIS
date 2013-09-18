class AddPassedToTestScore < ActiveRecord::Migration
  def self.up
    add_column :test_scores, :passed, :boolean
    add_column :test_types, :passable, :boolean
  end

  def self.down
    remove_column :test_types, :passable
    remove_column :test_scores, :passed
  end
end