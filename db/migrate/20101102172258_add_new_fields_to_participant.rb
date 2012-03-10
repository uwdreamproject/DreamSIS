class AddNewFieldsToParticipant < ActiveRecord::Migration
  def self.up
    add_column :people, :parent_graduated_college, :boolean
    add_column :people, :family_members_who_went_to_college, :string
    add_column :people, :family_members_graduated, :boolean
    add_column :people, :attended_school_outside_usa, :boolean
    add_column :people, :countries_attended_school_outside_usa, :string
    add_column :people, :attended_grade_1_outside_usa, :boolean
    add_column :people, :attended_grade_2_outside_usa, :boolean
    add_column :people, :attended_grade_3_outside_usa, :boolean
    add_column :people, :attended_grade_4_outside_usa, :boolean
    add_column :people, :attended_grade_5_outside_usa, :boolean
    add_column :people, :attended_grade_6_outside_usa, :boolean
    add_column :people, :attended_grade_7_outside_usa, :boolean
    add_column :people, :attended_grade_8_outside_usa, :boolean
    add_column :people, :attended_grade_9_outside_usa, :boolean
    add_column :people, :attended_grade_10_outside_usa, :boolean
    add_column :people, :attended_grade_11_outside_usa, :boolean
    add_column :people, :attended_grade_12_outside_usa, :boolean
    add_column :people, :african, :boolean
    add_column :people, :latino, :boolean
    add_column :people, :middle_eastern, :boolean
    add_column :people, :other_ethnicity, :boolean
    add_column :people, :african_american_heritage, :string
    add_column :people, :african_heritage, :string
    add_column :people, :american_indian_heritage, :string
    add_column :people, :asian_heritage, :string
    add_column :people, :hispanic_heritage, :string
    add_column :people, :latino_heritage, :string
    add_column :people, :middle_eastern_heritage, :string
    add_column :people, :pacific_islander_heritage, :string
    add_column :people, :caucasian_heritage, :string
    add_column :people, :other_heritage, :string
  end

  def self.down
    remove_column :people, :african_american_heritage
    remove_column :people, :african_heritage
    remove_column :people, :american_indian_heritage
    remove_column :people, :asian_heritage
    remove_column :people, :hispanic_heritage
    remove_column :people, :latino_heritage
    remove_column :people, :middle_eastern_heritage
    remove_column :people, :pacific_islander_heritage
    remove_column :people, :caucasian_heritage
    remove_column :people, :other_heritage
    remove_column :people, :other_ethnicity
    remove_column :people, :middle_eastern
    remove_column :people, :latino
    remove_column :people, :african
    remove_column :people, :attended_grade_12_outside_usa
    remove_column :people, :attended_grade_11_outside_usa
    remove_column :people, :attended_grade_10_outside_usa
    remove_column :people, :attended_grade_9_outside_usa
    remove_column :people, :attended_grade_8_outside_usa
    remove_column :people, :attended_grade_7_outside_usa
    remove_column :people, :attended_grade_6_outside_usa
    remove_column :people, :attended_grade_5_outside_usa
    remove_column :people, :attended_grade_4_outside_usa
    remove_column :people, :attended_grade_3_outside_usa
    remove_column :people, :attended_grade_2_outside_usa
    remove_column :people, :attended_grade_1_outside_usa
    remove_column :people, :countries_attended_school_outside_usa
    remove_column :people, :attended_school_outside_usa
    remove_column :people, :family_members_graduated
    remove_column :people, :family_members_who_went_to_college
    remove_column :people, :parent_graduated_college
  end
end
