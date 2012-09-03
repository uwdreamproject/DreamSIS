class AddOptionalTrainingsToEventGroup < ActiveRecord::Migration
  def self.up
    add_column :event_groups, :volunteer_training_optional, :boolean
    add_column :event_groups, :mentor_training_optional, :boolean
  end

  def self.down
    remove_column :event_groups, :mentor_training_optional
    remove_column :event_groups, :volunteer_training_optional
  end
end
