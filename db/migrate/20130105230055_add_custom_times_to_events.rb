class AddCustomTimesToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :student_start_time, :time
    add_column :events, :student_end_time, :time
    add_column :events, :volunteer_start_time, :time
    add_column :events, :volunteer_end_time, :time
    add_column :events, :mentor_start_time, :time
    add_column :events, :mentor_end_time, :time
  end

  def self.down
    remove_column :events, :mentor_end_time
    remove_column :events, :mentor_start_time
    remove_column :events, :volunteer_end_time
    remove_column :events, :volunteer_start_time
    remove_column :events, :student_end_time
    remove_column :events, :student_start_time
  end
end
