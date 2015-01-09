class AddUseNicknamesToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :display_nicknames_by_default, :boolean
  end
end
