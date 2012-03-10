class CreateIncomeLevels < ActiveRecord::Migration
  def self.up
    create_table :income_levels do |t|
      t.float :min_level
      t.float :max_level

      t.timestamps
    end
  end

  def self.down
    drop_table :income_levels
  end
end
