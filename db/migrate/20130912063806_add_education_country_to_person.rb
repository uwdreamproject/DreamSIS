class AddEducationCountryToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :education_country, :string
  end

  def self.down
    remove_column :people, :education_country
  end
end
