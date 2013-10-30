class AddRestoredToChange < ActiveRecord::Migration
  def self.up
    add_column :changes, :restored_at, :datetime
    add_column :changes, :restored_user_id, :integer
  end

  def self.down
    remove_column :changes, :restored_user_id
    remove_column :changes, :restored_at
  end
end
