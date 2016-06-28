class AddIndexToEventAttendance < ActiveRecord::Migration
  def change
    add_index :event_attendances, :event_id
    add_index :event_attendances, :person_id
    add_index :event_attendances, [:event_id, :person_id], unique: false
  end
end