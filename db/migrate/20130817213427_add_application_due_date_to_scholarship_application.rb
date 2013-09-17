class AddApplicationDueDateToScholarshipApplication < ActiveRecord::Migration
  def self.up
    add_column :scholarship_applications, :application_due_date, :date
  end

  def self.down
    remove_column :scholarship_applications, :application_due_date
  end
end
