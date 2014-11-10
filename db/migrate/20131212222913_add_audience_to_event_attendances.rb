class AddAudienceToEventAttendances < ActiveRecord::Migration
  def self.up
    add_column :event_attendances, :audience, :string
  end

  def self.down
    remove_column :event_attendances, :audience
  end
end
