class CreateActivityLogs < ActiveRecord::Migration
  def self.up
    create_table :activity_logs do |t|
      t.date :start_date
      t.date :end_date
      t.integer :mentor_id
      t.integer :direct_interaction_count
      t.integer :indirect_interaction_count
      t.text :student_time
      t.text :non_student_time
      t.text :highlight_note
      t.integer :customer_id
      t.timestamps
    end
    
    add_column :customers, :activity_log_student_time_categories, :text
    add_column :customers, :activity_log_non_student_time_categories, :text
  end

  def self.down
    remove_column :customers, :activity_log_non_student_time_categories
    remove_column :customers, :activity_log_student_time_categories
    
    drop_table :activity_logs
  end
end