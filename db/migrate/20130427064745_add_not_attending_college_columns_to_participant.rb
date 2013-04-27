class AddNotAttendingCollegeColumnsToParticipant < ActiveRecord::Migration
  def self.up
    add_column :people, :not_attending_college_reason, :string
  end
end
