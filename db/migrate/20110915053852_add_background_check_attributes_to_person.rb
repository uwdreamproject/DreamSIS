class AddBackgroundCheckAttributesToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :aliases, :text
    add_column :people, :crimes_against_persons_or_financial, :boolean
    add_column :people, :drug_related_crimes, :boolean
    add_column :people, :related_proceedings_crimes, :boolean
    add_column :people, :medicare_healthcare_crimes, :boolean
    add_column :people, :victim_crimes_explanation, :text
    add_column :people, :general_convictions, :boolean
    add_column :people, :general_convictions_explanation, :text
    add_column :people, :background_check_authorized_at, :datetime
  end

  def self.down
    remove_column :people, :background_check_authorized_at
    remove_column :people, :general_convictions_explanation
    remove_column :people, :general_convictions
    remove_column :people, :victim_crimes_explanation
    remove_column :people, :medicare_healthcare_crimes
    remove_column :people, :related_proceedings_crimes
    remove_column :people, :drug_related_crimes
    remove_column :people, :crimes_against_persons_or_financial
    remove_column :people, :aliases
  end
end
