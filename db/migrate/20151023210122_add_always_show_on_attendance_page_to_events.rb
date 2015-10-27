class AddAlwaysShowOnAttendancePageToEvents < ActiveRecord::Migration
  def change
    add_column :events, :always_show_on_attendance_pages, :boolean
  end
end
