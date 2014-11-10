class AddOpenToMentorsToEventGroups < ActiveRecord::Migration
  def self.up
    add_column :event_groups, :open_to_mentors, :boolean
  end

  def self.down
    remove_column :event_groups, :open_to_mentors
  end
end
