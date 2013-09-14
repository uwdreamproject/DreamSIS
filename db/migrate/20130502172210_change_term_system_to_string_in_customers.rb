class ChangeTermSystemToStringInCustomers < ActiveRecord::Migration
  def self.up
    change_column :customers, :term_system, :string
  end

  def self.down
    change_column :customers, :term_system, :boolean
  end
end