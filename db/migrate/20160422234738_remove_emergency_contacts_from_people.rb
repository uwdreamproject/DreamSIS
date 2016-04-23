class RemoveEmergencyContactsFromPeople < ActiveRecord::Migration
  def change
    remove_column :people, :emergency_name
    remove_column :people, :emergency_relationship
    remove_column :people, :emergency_number
    remove_column :people, :emergency_email
  end
end
