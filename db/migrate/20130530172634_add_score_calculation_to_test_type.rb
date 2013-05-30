class AddScoreCalculationToTestType < ActiveRecord::Migration
  def self.up
    add_column :test_types, :score_calculation_method, :string
  end

  def self.down
    remove_column :test_types, :score_calculation_method
  end
end
