class AddDescriptionsToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :student_description, :text
    add_column :events, :volunteer_description, :text
    add_column :events, :mentor_description, :text
  end

  def self.down
    remove_column :events, :mentor_description
    remove_column :events, :volunteer_description
    remove_column :events, :student_description
  end
end
