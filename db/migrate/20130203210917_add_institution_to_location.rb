class AddInstitutionToLocation < ActiveRecord::Migration
  def self.up
    add_column :locations, :institution_id, :integer
    add_column :locations, :country, :string
  end

  def self.down
    remove_column :locations, :country
    remove_column :locations, :institution_id
  end
end
