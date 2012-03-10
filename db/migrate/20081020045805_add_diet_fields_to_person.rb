class AddDietFieldsToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :vegetarian, :boolean
    add_column :people, :vegan, :boolean
  end

  def self.down
    remove_column :people, :vegan
    remove_column :people, :vegetarian
  end
end
