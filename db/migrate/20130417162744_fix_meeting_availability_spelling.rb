class FixMeetingAvailabilitySpelling < ActiveRecord::Migration
  def self.up
    rename_column :people, :meeting_avilability, :meeting_availability
    change_column :people, :meeting_availability, :text
  end

  def self.down
    change_column :people, :meeting_availability, :string
    rename_column :people, :meeting_availability, :meeting_avilability
  end
end