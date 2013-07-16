class CreateEnrollments < ActiveRecord::Migration
  def self.up
    create_table :enrollments do |t|
      t.string :type
      t.integer :participant_id
      t.integer :institution_id
      t.integer :high_school_id
      t.date :began_on
      t.date :ended_on
      t.string :enrollment_status
      t.string :class_level
      t.string :major_1
      t.string :major_1_cip
      t.string :major_2
      t.string :major_2_cip
      t.string :source
      t.integer :clearinghouse_request_id

      t.timestamps
    end
  end

  def self.down
    drop_table :enrollments
  end
end
