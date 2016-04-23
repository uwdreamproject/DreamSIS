class AddEmergencyContactBooleanToPerson < ActiveRecord::Migration
  def change
    add_column :people, :is_emergency_contact, :boolean
  end
end
