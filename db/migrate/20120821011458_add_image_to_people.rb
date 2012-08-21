class AddImageToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :avatar_image_url, :string
  end

  def self.down
    remove_column :people, :avatar_image_url
  end
end
