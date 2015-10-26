class AddCustomCssToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :stylesheet_url, :string
  end
end
