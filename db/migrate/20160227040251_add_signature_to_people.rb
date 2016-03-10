class AddSignatureToPeople < ActiveRecord::Migration
  def change
  	add_column :people, :intake_form_signature, :string
  end
end
