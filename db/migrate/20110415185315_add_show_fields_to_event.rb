class AddShowFieldsToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :show_for_participants, :boolean, default: true
    add_column :events, :show_for_mentors, :boolean, default: true
    add_column :events, :allow_rsvps, :boolean
  end

  def self.down
    remove_column :events, :allow_rsvps
    remove_column :events, :show_for_mentors
    remove_column :events, :show_for_participants
  end
end
