class AddTrainingToEventGroup < ActiveRecord::Migration
  def self.up
    add_column :event_groups, :volunteer_training_id, :integer
    add_column :event_groups, :mentor_training_id, :integer
  end

  def self.down
    remove_column :event_groups, :mentor_training_id
    remove_column :event_groups, :volunteer_training_id
  end
end
