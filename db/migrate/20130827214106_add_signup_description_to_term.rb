class AddSignupDescriptionToTerm < ActiveRecord::Migration
  def self.up
    add_column :terms, :signup_description, :text
  end

  def self.down
    remove_column :terms, :signup_description
  end
end
