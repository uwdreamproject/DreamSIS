class AddChoiceToCollegeApplication < ActiveRecord::Migration
  def self.up
    add_column :college_applications, :choice, :string
  end

  def self.down
    remove_column :college_applications, :choice
  end
end
