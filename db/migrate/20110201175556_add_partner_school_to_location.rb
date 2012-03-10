class AddPartnerSchoolToLocation < ActiveRecord::Migration
  def self.up
    add_column :locations, :partner_school, :boolean
  end

  def self.down
    remove_column :locations, :partner_school
  end
end
