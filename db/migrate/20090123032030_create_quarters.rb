class CreateQuarters < ActiveRecord::Migration
  def self.up
    create_table :quarters do |t|
      t.integer :year
      t.integer :quarter_code
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end

  def self.down
    drop_table :quarters
  end
end
