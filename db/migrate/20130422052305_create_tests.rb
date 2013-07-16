class CreateTests < ActiveRecord::Migration
  def self.up
    create_table :test_types do |t|
      t.string :name
      t.decimal :maximum_total_score
      t.text :sections

      t.timestamps
    end
  end

  def self.down
    drop_table :test_types
  end
end
