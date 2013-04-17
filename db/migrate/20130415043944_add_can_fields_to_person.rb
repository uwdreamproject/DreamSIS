class AddCanFieldsToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :preferred_contact_method, :string
    add_column :people, :preferred_phone, :string
    add_column :people, :facebook_id, :string
    add_column :people, :check_email_regularly, :boolean
    add_column :people, :student_id_number, :integer
    add_column :people, :birthplace, :string
    add_column :people, :married, :boolean
    add_column :people, :number_of_children, :integer
    add_column :people, :free_reduced_lunch_signed_up, :boolean
    add_column :people, :parent_type, :string
  end

  def self.down
    remove_column :people, :parent_type
    remove_column :people, :free_reduced_lunch_signed_up
    remove_column :people, :number_of_children
    remove_column :people, :married
    remove_column :people, :birthplace
    remove_column :people, :student_id_number
    remove_column :people, :check_email_regularly
    remove_column :people, :facebook_id
    remove_column :people, :preferred_phone
    remove_column :people, :preferred_contact_method
  end
end
