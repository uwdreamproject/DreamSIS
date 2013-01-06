class AddShowForVolunteersToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :show_for_students, :boolean, :default => true
    add_column :events, :show_for_volunteers, :boolean, :default => true
  end

  def self.down
    remove_column :events, :show_for_volunteers
    remove_column :events, :show_for_students
  end
end
