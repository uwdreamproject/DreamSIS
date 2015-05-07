class AddEarliestGradeLevelToObjectFilters < ActiveRecord::Migration
  def change
    unless column_exists? :object_filters, :earliest_grade_level
      add_column :object_filters, :earliest_grade_level, :integer
    end
  end
end
