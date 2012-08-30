class CreateTrainingCompletions < ActiveRecord::Migration
  def self.up
    create_table :training_completions do |t|
      t.integer :training_id
      t.integer :person_id
      t.datetime :completed_at

      t.timestamps
    end
  end

  def self.down
    drop_table :training_completions
  end
end
