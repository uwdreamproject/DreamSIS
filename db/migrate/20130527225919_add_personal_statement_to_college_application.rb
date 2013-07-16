class AddPersonalStatementToCollegeApplication < ActiveRecord::Migration
  def self.up
    add_column :college_applications, :personal_statement_started, :boolean
    add_column :college_applications, :personal_statement_completed, :boolean
  end

  def self.down
    remove_column :college_applications, :personal_statement_completed
    remove_column :college_applications, :personal_statement_started
  end
end
