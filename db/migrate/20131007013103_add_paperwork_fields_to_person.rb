class AddPaperworkFieldsToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :personal_statement_status, :string
    add_column :people, :resume_status, :string
    add_column :people, :activity_log_status, :string
    add_column :customers, :paperwork_status_options, :text
  end

  def self.down
    remove_column :customers, :paperwork_status_options
    remove_column :people, :activity_log_status
    remove_column :people, :resume_status
    remove_column :people, :personal_statement_status
  end
end