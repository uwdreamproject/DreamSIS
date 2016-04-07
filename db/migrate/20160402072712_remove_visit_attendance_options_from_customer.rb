class RemoveVisitAttendanceOptionsFromCustomer < ActiveRecord::Migration
  def change
    remove_column :customers, :visit_attendance_options
  end
end
