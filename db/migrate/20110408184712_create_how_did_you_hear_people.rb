class CreateHowDidYouHearPeople < ActiveRecord::Migration
  def self.up
    create_table :how_did_you_hear_options_people, id: false do |t|
      t.integer :person_id
      t.integer :how_did_you_hear_option_id
    end
  end

  def self.down
    drop_table :how_did_you_hear_options_people
  end
end
