class CreatePeoplePrograms < ActiveRecord::Migration
  def self.up
    create_table :people_programs, id: false do |t|
      t.integer :person_id
      t.integer :program_id
      t.timestamps
    end
    add_index :people_programs, [:person_id, :program_id]
  end

  def self.down
    drop_table :people_programs
  end
end