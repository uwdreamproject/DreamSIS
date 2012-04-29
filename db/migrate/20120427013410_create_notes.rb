class CreateNotes < ActiveRecord::Migration
  def self.up
    create_table :notes do |t|
      t.text :note
      t.integer :creator_id
      t.integer :updater_id
      t.integer :deleter_id
      t.integer :notable_id
      t.string :notable_type
      t.string :creator_name
      t.string :category
      t.string :access_level

      t.timestamps
    end
  end

  def self.down
    drop_table :notes
  end
end
