class AddConductFormContentToCustomers < ActiveRecord::Migration
  def self.up
    add_column :customers, :conduct_form_content, :text
  end

  def self.down
    remove_column :customers, :conduct_form_content
  end
end
