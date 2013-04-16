class AddMenteeLabelToCustomer < ActiveRecord::Migration
  def self.up
    add_column :customers, :mentee_label, :string
  end

  def self.down
    remove_column :customers, :mentee_label
  end
end
