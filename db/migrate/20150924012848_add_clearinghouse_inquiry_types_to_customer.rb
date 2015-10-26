class AddClearinghouseInquiryTypesToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :clearinghouse_customer_name, :string
    add_column :customers, :clearinghouse_entity_type, :string
    add_column :clearinghouse_requests, :inquiry_type, :string
  end
end