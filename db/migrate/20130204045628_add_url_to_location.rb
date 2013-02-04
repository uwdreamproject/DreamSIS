class AddUrlToLocation < ActiveRecord::Migration
  def self.up
    add_column :locations, :website_url, :string
  end

  def self.down
    remove_column :locations, :website_url
  end
end
