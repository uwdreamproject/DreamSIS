class AddNotTargetLabelToCustomer < ActiveRecord::Migration
  def self.up
    add_column :customers, :not_target_label, :string
  end

  def self.down
    remove_column :customers, :not_target_label
  end
end
