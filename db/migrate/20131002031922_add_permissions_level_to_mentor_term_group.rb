class AddPermissionsLevelToMentorTermGroup < ActiveRecord::Migration
  def self.up
    add_column :mentor_term_groups, :permissions_level, :string
  end

  def self.down
    remove_column :mentor_term_groups, :permissions_level
  end
end
