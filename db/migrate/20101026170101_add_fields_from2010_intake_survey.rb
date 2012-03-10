class AddFieldsFrom2010IntakeSurvey < ActiveRecord::Migration
  def self.up
    add_column :people, :parent_only_speaks_language, :string
    add_column :people, :kosher, :boolean
    add_column :people, :halal, :boolean
    add_column :people, :foster_youth, :boolean
    add_column :people, :plans_after_high_school, :string
    add_column :people, :live_with_mother, :boolean
    add_column :people, :live_with_father, :boolean
  end

  def self.down
    remove_column :people, :live_with_father
    remove_column :people, :live_with_mother
    remove_column :people, :plans_after_high_school
    remove_column :people, :foster_youth
    remove_column :people, :halal
    remove_column :people, :kosher
    remove_column :people, :parent_only_speaks_language
  end
end
