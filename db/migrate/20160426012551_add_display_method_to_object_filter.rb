class AddDisplayMethodToObjectFilter < ActiveRecord::Migration
  def change
    add_column :object_filters, :warn_if_false, :boolean
  end
end
