class AddAdminToEventAttendance < ActiveRecord::Migration
  def self.up
    add_column :event_attendances, :admin, :boolean
  end

  def self.down
    remove_column :event_attendances, :admin
  end
end
