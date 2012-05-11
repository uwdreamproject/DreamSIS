class AddCounterCacheToParticipantGroups < ActiveRecord::Migration
  def self.up
    add_column :participant_groups, :participants_count, :integer, :default => 0
    
    ParticipantGroup.reset_column_information
    ParticipantGroup.all.each do |g|
      ParticipantGroup.update_counters g.id, :participants_count => g.participants.length
    end
  end

  def self.down
    remove_column :participant_groups, :participants_count
  end
end
