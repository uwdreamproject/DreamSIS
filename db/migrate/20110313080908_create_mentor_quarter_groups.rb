class CreateMentorQuarterGroups < ActiveRecord::Migration
  def self.up
    create_table :mentor_quarter_groups do |t|
      t.integer :quarter_id
      t.integer :location_id
      t.string :title
      t.string :course_id
      t.string :times
      t.time :depart_time
      t.time :return_time
      t.integer :capacity
      t.boolean :none_option

      t.timestamps
    end
    
    remove_column :mentor_quarters, :quarter_id
  end

  def self.down
    add_column :mentor_quarters, :quarter_id, :integer
    drop_table :mentor_quarter_groups
  end
end
