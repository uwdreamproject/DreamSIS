class ChangeMentorQuarter < ActiveRecord::Migration
  def self.up
    rename_column :mentor_quarters, :location_id, :mentor_quarter_group_id
  end

  def self.down
    remove_column :mentor_quarters, :lead
  end
end