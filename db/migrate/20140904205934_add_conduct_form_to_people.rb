class AddConductFormToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :conduct_form_signed_at, :datetime
    add_column :people, :conduct_form_signature, :string
  end

  def self.down
    remove_column :people, :conduct_form_signed_at
    remove_column :people, :conduct_form_signature
  end
end
