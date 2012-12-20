class AddSchoolCodeToLocation < ActiveRecord::Migration
  def self.up
    add_column :locations, :school_code, :string
  end

  def self.down
    remove_column :locations, :school_code
  end
end
