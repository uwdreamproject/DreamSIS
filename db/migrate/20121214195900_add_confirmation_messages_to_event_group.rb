class AddConfirmationMessagesToEventGroup < ActiveRecord::Migration
  def self.up
    add_column :event_groups, :student_confirmation_message, :text
    add_column :event_groups, :volunteer_confirmation_message, :text
    add_column :event_groups, :mentor_confirmation_message, :text
    add_column :event_groups, :hide_description_in_confirmation_message, :boolean
  end

  def self.down
    remove_column :event_groups, :hide_description_in_confirmation_message
    remove_column :event_groups, :mentor_confirmation_message
    remove_column :event_groups, :volunteer_confirmation_message
    remove_column :event_groups, :student_confirmation_message
  end
end
