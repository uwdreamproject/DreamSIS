class AddEventCoordinatorToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :event_coordinator_id, :integer
  end

  def self.down
    remove_column :events, :event_coordinator_id
  end
end
