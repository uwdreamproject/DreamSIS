class AddPositionToObjectFilter < ActiveRecord::Migration
  def change
    add_column :object_filters, :position, :integer
  end
end
