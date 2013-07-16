class AddBackupEmailAndGlutenFreeToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :email2, :string
    add_column :people, :gluten_free, :boolean
  end

  def self.down
    remove_column :people, :gluten_free
    remove_column :people, :email2
  end
end
