class AddDatesToObjectFilters < ActiveRecord::Migration
  def self.up
    add_column :object_filters, :start_display_at, :date
    add_column :object_filters, :end_display_at, :date
  end

  def self.down
    remove_column :object_filters, :end_display_at
    remove_column :object_filters, :start_display_at
  end
end