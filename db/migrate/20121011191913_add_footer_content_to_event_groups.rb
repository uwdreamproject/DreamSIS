class AddFooterContentToEventGroups < ActiveRecord::Migration
  def self.up
    add_column :event_groups, :footer_content, :text
  end

  def self.down
    remove_column :event_groups, :footer_content
  end
end
