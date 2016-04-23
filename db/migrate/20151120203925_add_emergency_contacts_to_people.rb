class AddEmergencyContactsToPeople < ActiveRecord::Migration
  def change
    add_column :people, :emergency_name, :string
    add_column :people, :emergency_relationship, :string
    add_column :people, :emergency_number, :string
    add_column :people, :emergency_email, :string
  end
end
