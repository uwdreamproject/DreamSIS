class CreateScholarshipApplications < ActiveRecord::Migration
  def self.up
    create_table :scholarship_applications do |t|
      t.integer :scholarship_id
      t.integer :participant_id
      t.boolean :awarded
      t.boolean :renewable
      t.boolean :accepted
      t.decimal :amount
      t.date :date_applied
      t.text :restrictions

      t.timestamps
    end
  end

  def self.down
    drop_table :scholarship_applications
  end
end
