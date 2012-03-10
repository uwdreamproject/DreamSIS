class AddNotesToScholarshipApplication < ActiveRecord::Migration
  def self.up
    add_column :scholarship_applications, :notes, :text
  end

  def self.down
    remove_column :scholarship_applications, :notes
  end
end
