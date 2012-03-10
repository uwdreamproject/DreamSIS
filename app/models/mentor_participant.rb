class MentorParticipant < ActiveRecord::Base

  belongs_to :mentor
  belongs_to :participant
  
  validates_presence_of :mentor_id, :participant_id
  validates_uniqueness_of :mentor_id, :scope => :participant_id

  default_scope :order => "people.lastname, people.firstname", :joins => :participant
  
  def destroy
    update_attribute :deleted_at, Time.now
    # MentorQuarterGroup.decrement_counter(:mentor_quarters_count, mentor_quarter_group.id)
  end
  
  def deleted?
    !deleted_at.nil?
  end
  

end
