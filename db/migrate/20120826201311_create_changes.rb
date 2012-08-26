class CreateChanges < ActiveRecord::Migration
  def self.up
    create_table :changes do |t|
      t.integer  "change_loggable_id"
      t.string   "change_loggable_type"
      t.text     "changes"
      t.integer  "user_id"
      t.string   "action_type"
      t.timestamps
    end
    add_index "changes", ["change_loggable_id", "change_loggable_type"], :name => "index_changes_on_changable"
  end

  def self.down
    drop_table :changes
  end
end
