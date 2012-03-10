class AddVolunteerToMentorQuarters < ActiveRecord::Migration
  def self.up
    add_column :mentor_quarters, :volunteer, :boolean
  end

  def self.down
    remove_column :mentor_quarters, :volunteer
  end
end
