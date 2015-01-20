class AddRsvpDisablingToEventGroups < ActiveRecord::Migration
  def change
    add_column :event_groups, :mentor_hours_prior_disable_cancel, :integer
    add_column :event_groups, :student_hours_prior_disable_cancel, :integer
    add_column :event_groups, :volunteer_hours_prior_disable_cancel, :integer
    add_column :event_groups, :mentor_disable_message, :text
    add_column :event_groups, :student_disable_message, :text
    add_column :event_groups, :volunteer_disable_message, :text
  end
end
