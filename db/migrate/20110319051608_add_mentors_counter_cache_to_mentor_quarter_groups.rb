class AddMentorsCounterCacheToMentorQuarterGroups < ActiveRecord::Migration
  def self.up
    add_column :mentor_quarter_groups, :mentor_quarters_count, :integer, :default => 0
    
    MentorQuarterGroup.reset_column_information
    MentorQuarterGroup.all.each do |g|
      MentorQuarterGroup.update_counters g.id, :mentor_quarters_count => g.mentor_quarters.length
    end
  end

  def self.down
    remove_column :mentor_quarter_groups, :mentor_quarters_count
  end
end
