class AddTypeToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :type, :string
  end

  def self.down
    remove_column :events, :type
  end
end
