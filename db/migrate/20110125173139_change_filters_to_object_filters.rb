class ChangeFiltersToObjectFilters < ActiveRecord::Migration
  def self.up
    rename_table "filters", "object_filters"
  end

  def self.down
    rename_table "object_filters", "filters"
  end
end
