class AddCollegeAttendingIdToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :college_attending_id, :integer
  end

  def self.down
    remove_column :people, :college_attending_id
  end
end
