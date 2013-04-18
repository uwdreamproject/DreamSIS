class AddExperimentalToCustomer < ActiveRecord::Migration
  def self.up
    add_column :customers, :experimental, :boolean
  end

  def self.down
    remove_column :customers, :experimental
  end
end
