class AddLivesWithToParent < ActiveRecord::Migration
  def self.up
    add_column :people, :lives_with, :boolean
  end

  def self.down
    remove_column :people, :lives_with
  end
end
