class AddRenewableYearsAndDefaultValuesToScholarships < ActiveRecord::Migration
  def self.up
    add_column :scholarships, :default_renewable_years, :integer
    add_column :scholarships, :default_full_ride, :boolean
    add_column :scholarships, :default_gap_funding, :boolean
    add_column :scholarships, :default_living_stipend, :boolean
    add_column :scholarships, :default_renewable, :boolean
    add_column :scholarship_applications, :renewable_years, :integer
    add_column :scholarship_applications, :full_ride, :boolean
    add_column :scholarship_applications, :gap_funding, :boolean
    add_column :scholarship_applications, :living_stipend, :boolean
    add_column :scholarship_applications, :institution_id, :integer
  end

  def self.down
    remove_column :scholarship_applications, :institution_id
    remove_column :scholarship_applications, :living_stipend
    remove_column :scholarship_applications, :gap_funding
    remove_column :scholarship_applications, :full_ride
    remove_column :scholarship_applications, :renewable_years
    remove_column :scholarships, :default_renewable
    remove_column :scholarships, :default_living_stipend
    remove_column :scholarships, :default_gap_funding
    remove_column :scholarships, :default_full_ride
    remove_column :scholarships, :default_renewable_years
  end
end