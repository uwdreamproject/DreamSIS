class ChangeParticipantCollegesToCollegeApplications < ActiveRecord::Migration
  def self.up
    rename_table :participant_colleges, :college_applications
  end

  def self.down
    rename_table :college_applications, :participant_colleges
  end
end
