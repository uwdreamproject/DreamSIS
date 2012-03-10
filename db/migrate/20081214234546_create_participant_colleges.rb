class CreateParticipantColleges < ActiveRecord::Migration
  def self.up
    create_table :participant_colleges do |t|
      t.integer :participant_id
      t.integer :institution_id
      t.datetime :date_applied
      t.datetime :date_notified
      t.string :decision

      t.timestamps
    end
  end

  def self.down
    drop_table :participant_colleges
  end
end
