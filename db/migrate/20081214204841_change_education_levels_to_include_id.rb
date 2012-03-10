class ChangeEducationLevelsToIncludeId < ActiveRecord::Migration
  def self.up
    rename_column :people, :mother_education_level, :mother_education_level_id
    rename_column :people, :father_education_level, :father_education_level_id
  end

  def self.down
    rename_column :people, :mother_education_level_id, :mother_education_level
    rename_column :people, :father_education_level_id, :father_education_level
  end
end
