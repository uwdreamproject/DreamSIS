class AddSignatureToPeople < ActiveRecord::Migration
  def change
  	add_column :people, :intake_form_signature, :string
  	add_column :people, :intake_form_signed_at, :boolean
  end
end
