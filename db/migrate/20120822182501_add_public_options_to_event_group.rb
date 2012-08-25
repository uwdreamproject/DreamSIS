class AddPublicOptionsToEventGroup < ActiveRecord::Migration
  def self.up
    add_column :event_groups, :allow_external_students, :boolean
    add_column :event_groups, :allow_external_volunteers, :boolean
  end

  def self.down
    remove_column :event_groups, :allow_external_volunteers
    remove_column :event_groups, :allow_external_students
  end
end
