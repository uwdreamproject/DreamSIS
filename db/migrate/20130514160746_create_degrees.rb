class CreateDegrees < ActiveRecord::Migration
  def self.up
    create_table :degrees do |t|
      t.string :type
      t.integer :participant_id
      t.integer :institution_id
      t.integer :high_school_id
      t.date :graduated_on
      t.string :degree_title
      t.string :major_1
      t.string :major_1_cip
      t.string :major_2
      t.string :major_2_cip
      t.string :major_3
      t.string :major_3_cip
      t.string :major_4
      t.string :major_4_cip
      t.string :source
      t.integer :clearinghouse_request_id

      t.timestamps
    end
  end

  def self.down
    drop_table :degrees
  end
end
