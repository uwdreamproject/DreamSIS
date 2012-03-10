class CreateEventGroups < ActiveRecord::Migration
  def self.up
    create_table :event_groups do |t|
      t.string :name
      t.text :description
      t.integer :event_type_id

      t.timestamps
    end
  end

  def self.down
    drop_table :event_groups
  end
end
