class AddCourseIdsToQuarters < ActiveRecord::Migration
  def self.up
    add_column :quarters, :course_ids, :text
  end

  def self.down
    remove_column :quarters, :course_ids
  end
end
