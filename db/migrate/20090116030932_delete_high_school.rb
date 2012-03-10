class DeleteHighSchool < ActiveRecord::Migration
  def self.up
    drop_table :high_schools
  end

  def self.down
    create_table :high_schools do |t|
      t.string :name
      t.timestamps
    end
  end
end
