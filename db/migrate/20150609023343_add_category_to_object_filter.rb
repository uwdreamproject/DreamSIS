class AddCategoryToObjectFilter < ActiveRecord::Migration
  def change
    add_column :object_filters, :category, :string
  end
end
