class AddParentFieldsToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :child_id, :integer
    add_column :people, :relationship_to_child, :string
    add_column :people, :occupation, :string
    add_column :people, :annual_income, :decimal
    add_column :people, :needs_interpreter, :boolean
    add_column :people, :meeting_avilability, :text
  end

  def self.down
    remove_column :people, :meeting_avilability
    remove_column :people, :needs_interpreter
    remove_column :people, :annual_income
    remove_column :people, :occupation
    remove_column :people, :relationship_to_child
    remove_column :people, :child_id
  end
end
