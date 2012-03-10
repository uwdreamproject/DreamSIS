class AddLinkedMentorQuarterGroupToMentorQuarterGroup < ActiveRecord::Migration
  def self.up
    add_column :mentor_quarter_groups, :linked_group_id, :integer
  end

  def self.down
    remove_column :mentor_quarter_groups, :linked_group_id
  end
end
