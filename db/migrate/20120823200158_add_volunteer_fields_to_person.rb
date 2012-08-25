class AddVolunteerFieldsToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :organization, :string
    add_column :people, :shirt_size, :string
  end

  def self.down
    remove_column :people, :shirt_size
    remove_column :people, :organization
  end
end
