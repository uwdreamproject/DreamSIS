class AddBackgroundCheckValidityLengthToCustomers < ActiveRecord::Migration
  def self.up
    add_column :customers, :background_check_validity_length, :integer
  end

  def self.down
    remove_column :customers, :background_check_validity_length
  end
end
