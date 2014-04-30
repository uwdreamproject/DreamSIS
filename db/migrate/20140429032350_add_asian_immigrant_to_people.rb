class AddAsianImmigrantToPeople < ActiveRecord::Migration
  def self.up
    rename_column :people, :asian, :asian_american
    rename_column :people, :asian_heritage, :asian_american_heritage
    add_column :people, :asian, :boolean
    add_column :people, :asian_heritage, :string
  end

  def self.down
    remove_column :people, :asian_heritage
    remove_column :people, :asian
    rename_column :people, :asian_american_heritage, :asian_heritage
    rename_column :people, :asian_american, :asian
  end
end