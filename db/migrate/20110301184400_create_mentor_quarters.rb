class CreateMentorQuarters < ActiveRecord::Migration
  def self.up
    create_table :mentor_quarters do |t|
      t.integer :mentor_id
      t.integer :location_id
      t.integer :quarter_id
      t.boolean :lead
      t.datetime :deleted_at

      t.timestamps
    end
  end

  def self.down
    drop_table :mentor_quarters
  end
end
