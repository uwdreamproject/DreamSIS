class AddDriverFormFieldsToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :driver_form_signature, :string
    add_column :people, :driver_form_signed_at, :datetime
    add_column :people, :driver_form_offense_response, :string
    add_column :people, :has_previous_driving_convictions, :boolean
    #add_column :people, :driver_approved_at, :datetime
    add_column :people, :driver_form_remarks, :string
  end

  def self.down
    remove_column :people, :driver_form_signature
    remove_column :people, :driver_form_signed_at
    remove_column :people, :driver_form_offense_response
    remove_column :people, :has_previous_driving_convictions
   # remove_column :people, :driver_approved_at
    remove_column :people, :driver_form_remarks
  end
end
