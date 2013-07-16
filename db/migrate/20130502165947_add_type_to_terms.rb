class AddTypeToTerms < ActiveRecord::Migration
  def self.up
    add_column :terms, :type, :string
    
    Term.all.each{ |term| term.update_attribute(:type, "Quarter") }  # Everything from before should still behave like Quarters.
  end

  def self.down
    remove_column :terms, :type
  end
end
