class CreateClearinghouseRequests < ActiveRecord::Migration
  def self.up
    create_table :clearinghouse_requests do |t|
      t.integer :customer_id
      t.integer :created_by
      t.string :submitted_filename
      t.datetime :submitted_at
      t.datetime :retrieved_at
      t.text :participant_ids
      t.text :ftp_password
      t.integer :number_of_records_submitted
      t.integer :number_of_records_returned

      t.timestamps
    end
    
    add_column :customers, :clearinghouse_customer_number, :integer
    add_column :customers, :clearinghouse_contract_start_date, :date
    add_column :customers, :clearinghouse_number_of_submissions_allowed, :integer
  end

  def self.down
    remove_column :customers, :clearinghouse_number_of_submissions_allowed
    remove_column :customers, :clearinghouse_contract_start_date
    remove_column :customers, :clearinghouse_customer_number
    drop_table :clearinghouse_requests
  end
end
