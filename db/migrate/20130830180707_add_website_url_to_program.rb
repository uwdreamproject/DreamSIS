class AddWebsiteUrlToProgram < ActiveRecord::Migration
  def self.up
    add_column :programs, :website_url, :string
  end

  def self.down
    remove_column :programs, :website_url
  end
end
