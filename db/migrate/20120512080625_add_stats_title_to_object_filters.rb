class AddStatsTitleToObjectFilters < ActiveRecord::Migration
  def self.up
    add_column :object_filters, :opposite_title, :string
    add_column :object_filters, :target_percentage, :integer
    add_column :object_filters, :warning_threshold, :integer
  end

  def self.down
    remove_column :object_filters, :warning_threshold
    remove_column :object_filters, :target_percentage
    remove_column :object_filters, :opposite_title
  end
end
