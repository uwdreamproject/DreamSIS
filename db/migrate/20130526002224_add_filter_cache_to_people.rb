class AddFilterCacheToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :filter_cache, :text
  end

  def self.down
    remove_column :people, :filter_cache
  end
end
