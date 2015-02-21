class AddLeadershipTagsToMentors < ActiveRecord::Migration
  def self.up
    add_column :people, :tags, :text
  end

  def self.down
    remove_column :people, :tags
  end
end
