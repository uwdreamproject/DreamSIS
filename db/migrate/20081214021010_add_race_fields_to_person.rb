class AddRaceFieldsToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :hispanic, :boolean
    add_column :people, :african_american, :boolean
    add_column :people, :american_indian, :boolean
    add_column :people, :asian, :boolean
    add_column :people, :pacific_islander, :boolean
    add_column :people, :caucasian, :boolean
    add_column :people, :ethnicity_details, :string
  end

  def self.down
    remove_column :people, :ethnicity_details
    remove_column :people, :caucasian
    remove_column :people, :pacific_islander
    remove_column :people, :asian
    remove_column :people, :american_indian
    remove_column :people, :african_american
    remove_column :people, :hispanic
  end
end
