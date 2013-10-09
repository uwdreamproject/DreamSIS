class AddCollegeAttendingIndexToPerson < ActiveRecord::Migration
  def self.up
    add_index :people, :college_attending_id
  end

  def self.down
    remove_index :people, :college_attending_id
  end
end