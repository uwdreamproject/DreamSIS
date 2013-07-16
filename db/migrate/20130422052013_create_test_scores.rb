class CreateTestScores < ActiveRecord::Migration
  def self.up
    create_table :test_scores do |t|
      t.integer :participant_id
      t.integer :test_type_id
      t.datetime :registered_at
      t.datetime :taken_at
      t.decimal :total_score
      t.text :section_scores

      t.timestamps
    end
  end

  def self.down
    drop_table :test_scores
  end
end
