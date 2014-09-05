class AddPreviousResidenceJurisdictionsToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :previous_residence_jurisdictions, :string
  end

  def self.down
    remove_column :people, :previous_residence_jurisdictions
  end
end
