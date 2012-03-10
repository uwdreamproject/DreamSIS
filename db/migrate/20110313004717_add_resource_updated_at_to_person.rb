class AddResourceUpdatedAtToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :resource_cache_updated_at, :datetime
  end

  def self.down
    remove_column :people, :resource_cache_updated_at
  end
end
