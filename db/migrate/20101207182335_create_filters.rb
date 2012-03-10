class CreateFilters < ActiveRecord::Migration
  def self.up
    create_table :filters do |t|
      t.string :object_class
      t.string :title
      t.text :criteria

      t.timestamps
    end
  end

  def self.down
    drop_table :filters
  end
end
