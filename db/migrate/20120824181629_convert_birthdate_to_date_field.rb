class ConvertBirthdateToDateField < ActiveRecord::Migration
  def self.up
    change_column :people, :birthdate, :date
  end

  def self.down
    change_column :people, :birthdate, :string
  end
end
