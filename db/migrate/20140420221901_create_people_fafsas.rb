class CreatePeopleFafsas < ActiveRecord::Migration
  def self.up
    create_table :people_fafsas do |t|
      t.integer :person_id
      t.integer :year
      t.datetime :fafsa_submitted_at
      t.datetime :wasfa_submitted_at
      t.boolean :not_applicable
      t.timestamps
    end
    add_index :people_fafsas, [:person_id, :year]
  end

  def self.down
    drop_table :people_fafsas
  end
end
