class AddMissingFieldsToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :first_generation, :boolean
    add_column :people, :computer_at_home, :boolean
    add_column :people, :dietary_restrictions, :string
  end

  def self.down
    remove_column :people, :dietary_restrictions
    remove_column :people, :computer_at_home
    remove_column :people, :first_generation
  end
end
