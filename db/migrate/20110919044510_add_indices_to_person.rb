class AddIndicesToPerson < ActiveRecord::Migration
  def self.up
    add_index :people, :firstname
    add_index :people, :lastname
    add_index :people, :display_name
    add_index :people, :uw_net_id
  end

  def self.down
    remove_index :people, :uw_net_id
    remove_index :people, :display_name
    remove_index :people, :lastname
    remove_index :people, :firstname
  end
end
