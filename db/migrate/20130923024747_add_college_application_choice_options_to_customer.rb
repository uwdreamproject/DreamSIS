class AddCollegeApplicationChoiceOptionsToCustomer < ActiveRecord::Migration
  def self.up
    add_column :customers, :college_application_choice_options, :text
  end

  def self.down
    remove_column :customers, :college_application_choice_options
  end
end
