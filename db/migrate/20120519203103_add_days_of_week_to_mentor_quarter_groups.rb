class AddDaysOfWeekToMentorQuarterGroups < ActiveRecord::Migration
  def self.up
    add_column :mentor_quarter_groups, :day_of_week, :string
  end

  def self.down
    remove_column :mentor_quarter_groups, :day_of_week
  end
end
