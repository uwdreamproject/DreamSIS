class AddAllowSignupsToQuarter < ActiveRecord::Migration
  def self.up
    add_column :quarters, :allow_signups, :boolean
  end

  def self.down
    remove_column :quarters, :allow_signups
  end
end
