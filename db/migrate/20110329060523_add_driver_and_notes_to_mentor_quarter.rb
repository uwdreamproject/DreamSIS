class AddDriverAndNotesToMentorQuarter < ActiveRecord::Migration
  def self.up
    add_column :mentor_quarters, :driver, :boolean
    add_column :mentor_quarters, :notes, :text
  end

  def self.down
    remove_column :mentor_quarters, :notes
    remove_column :mentor_quarters, :driver
  end
end
