class CreateParticipantGroups < ActiveRecord::Migration
  def self.up
    create_table :participant_groups do |t|
      t.string :title
      t.integer :grad_year
      t.integer :location_id
      t.timestamps
    end
    add_column :people, :participant_group_id, :integer
  end

  def self.down
    remove_column :people, :participant_group_id
    drop_table :participant_groups
  end
end
