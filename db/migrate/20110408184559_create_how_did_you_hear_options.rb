class CreateHowDidYouHearOptions < ActiveRecord::Migration
  def self.up
    create_table :how_did_you_hear_options do |t|
      t.string :name
      t.boolean :show_for_participants
      t.boolean :show_for_mentors

      t.timestamps
    end
  end

  def self.down
    drop_table :how_did_you_hear_options
  end
end
