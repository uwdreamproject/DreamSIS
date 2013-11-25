class AddVisitAttendanceOptionsToCustomer < ActiveRecord::Migration
  def self.up
    add_column :customers, :visit_attendance_options, :text
		add_column :event_attendances, :attendance_option, :string
  end

  def self.down
		remove_column :event_attendances, :attendance_option
    remove_column :customers, :visit_attendance_options
  end
end