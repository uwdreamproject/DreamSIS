class AddTimeTbaToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :time_tba, :boolean
  end

  def self.down
    remove_column :events, :time_tba
  end
end
