class ChangeEventTypeDescriptionToText < ActiveRecord::Migration
  def self.up
    remove_column :event_types, :description
    add_column :event_types, :description, :text
  end

  def self.down
    remove_column :event_types, :description
    add_column :event_types, :description, :string
  end
end
