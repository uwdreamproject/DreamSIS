class AddCourseDependenciesToTerm < ActiveRecord::Migration
  def self.up
    add_column :terms, :course_dependencies, :text
  end

  def self.down
    remove_column :terms, :course_dependencies
  end
end
