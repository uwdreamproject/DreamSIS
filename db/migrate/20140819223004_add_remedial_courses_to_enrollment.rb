class AddRemedialCoursesToEnrollment < ActiveRecord::Migration
  def change
    add_column :enrollments, :placed_in_remedial_math, :boolean
    add_column :enrollments, :placed_in_remedial_english, :boolean
  end
end
