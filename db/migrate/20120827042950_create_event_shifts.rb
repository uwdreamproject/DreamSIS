class CreateEventShifts < ActiveRecord::Migration
  def self.up
    create_table :event_shifts do |t|
      t.string :title
      t.string :description
      t.integer :event_id
      t.time :start_time
      t.time :end_time
      t.boolean :show_for_volunteers
      t.boolean :show_for_mentors

      t.timestamps
    end
    
    add_column :event_attendances, :event_shift_id, :integer
  end

  def self.down
    remove_column :event_attendances, :event_shift_id
    drop_table :event_shifts
  end
end
