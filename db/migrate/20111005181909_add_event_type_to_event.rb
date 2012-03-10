class AddEventTypeToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :event_type_id, :integer
    add_column :events, :event_group_id, :integer
  end

  def self.down
    remove_column :events, :event_group_id
    remove_column :events, :event_type_id
  end
end
