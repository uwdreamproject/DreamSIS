class CreateEventAttendances < ActiveRecord::Migration
  def self.up
    create_table :event_attendances do |t|
      t.integer :person_id
      t.integer :event_id
      t.boolean :rsvp
      t.boolean :attended

      t.timestamps
    end
  end

  def self.down
    drop_table :event_attendances
  end
end
