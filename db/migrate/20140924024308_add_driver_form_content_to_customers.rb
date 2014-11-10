class AddDriverFormContentToCustomers < ActiveRecord::Migration
  def self.up
    add_column :customers, :driver_form_content, :text
    add_column :customers, :send_driver_form_emails, :boolean
  end

  def self.down
    remove_column :customers, :driver_form_content
    remove_column :customers, :send_driver_form_emails
  end
end