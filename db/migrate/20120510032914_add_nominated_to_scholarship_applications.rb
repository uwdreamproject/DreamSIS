class AddNominatedToScholarshipApplications < ActiveRecord::Migration
  def self.up
    add_column :scholarship_applications, :nominated, :boolean
  end

  def self.down
    remove_column :scholarship_applications, :nominated
  end
end
