class AddInactiveAndParentEducationFieldsToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :inactive, :boolean
    add_column :people, :mother_education_level, :integer
    add_column :people, :father_education_level, :integer
    add_column :people, :mother_education_country, :string
    add_column :people, :father_education_country, :string
  end

  def self.down
    remove_column :people, :father_education_country
    remove_column :people, :mother_education_country
    remove_column :people, :father_education_level
    remove_column :people, :mother_education_level
    remove_column :people, :inactive
  end
end
