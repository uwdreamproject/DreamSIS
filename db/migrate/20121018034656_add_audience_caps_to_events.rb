class AddAudienceCapsToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :student_capacity, :integer
    add_column :events, :mentor_capacity, :integer
    add_column :events, :volunteer_capacity, :integer
  end

  def self.down
    remove_column :events, :volunteer_capacity
    remove_column :events, :mentor_capacity
    remove_column :events, :student_capacity
  end
end
