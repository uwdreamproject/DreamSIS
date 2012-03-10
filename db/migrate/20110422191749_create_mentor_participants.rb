class CreateMentorParticipants < ActiveRecord::Migration
  def self.up
    create_table :mentor_participants do |t|
      t.integer :mentor_id
      t.integer :participant_id
      t.datetime :deleted_at

      t.timestamps
    end
    
    add_column :people, :mentor_participant_count, :integer
  end

  def self.down
    remove_column :people, :mentor_participant_count
    drop_table :mentor_participants
  end
end
