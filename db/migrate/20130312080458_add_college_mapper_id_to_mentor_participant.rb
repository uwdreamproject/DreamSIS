class AddCollegeMapperIdToMentorParticipant < ActiveRecord::Migration
  def self.up
    add_column :mentor_participants, :college_mapper_id, :integer
  end

  def self.down
    remove_column :mentor_participants, :college_mapper_id
  end
end
