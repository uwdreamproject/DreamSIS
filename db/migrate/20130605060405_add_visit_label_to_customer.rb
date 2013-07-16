class AddVisitLabelToCustomer < ActiveRecord::Migration
  def self.up
    add_column :customers, :visit_label, :string
  end

  def self.down
    remove_column :customers, :visit_label
  end
end
