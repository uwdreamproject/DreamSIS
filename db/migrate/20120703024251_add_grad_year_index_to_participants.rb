class AddGradYearIndexToParticipants < ActiveRecord::Migration
  def self.up
    add_index :people, :grad_year
  end

  def self.down
    remove_index :people, :grad_year
  end
end
