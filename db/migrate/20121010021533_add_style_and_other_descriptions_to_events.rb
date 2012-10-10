class AddStyleAndOtherDescriptionsToEvents < ActiveRecord::Migration
  def self.up
    add_column :event_groups, :stylesheet_url, :string
    add_column :event_groups, :student_description, :text
    add_column :event_groups, :volunteer_description, :text
    add_column :event_groups, :mentor_description, :text
  end

  def self.down
    remove_column :event_groups, :mentor_description
    remove_column :event_groups, :volunteer_description
    remove_column :event_groups, :student_description
    remove_column :event_groups, :stylesheet_url
  end
end
