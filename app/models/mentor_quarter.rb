class MentorQuarter < ActiveRecord::Base
  belongs_to :mentor_quarter_group, :counter_cache => true
  belongs_to :mentor
  
  validates_presence_of :mentor_id, :mentor_quarter_group_id
  validates_uniqueness_of :mentor_id, :scope => :mentor_quarter_group_id, :message => "is already a member of this group"

  delegate :quarter, :quarter_id, :location, :title, :location_id, :to => :mentor_quarter_group
  delegate :fullname, :email, :reg_id, :participants, :mentor_participants, :to => :mentor
  
  default_scope :order => "people.lastname, people.firstname", :joins => :mentor
  
  # after_create :add_to_group
  
  def destroy
    update_attribute :deleted_at, Time.now
    MentorQuarterGroup.decrement_counter(:mentor_quarters_count, mentor_quarter_group.id)
    # delete_from_group
  end
  
  def deleted?
    !deleted_at.nil?
  end

  attr_accessor :new_participant_id
  
  def new_participant_id=(new_participant_id)
    mentor.participants << Participant.find(new_participant_id) rescue false
  end
  
  # Adds this mentor to the GroupResource for the associated Quarter. This method doesn't check if the
  # mentor is already a part of the group or not because the UW Groups Service will simply ignore the duplicate.
  def add_to_group
    quarter.group_resource.add_member(mentor.uw_net_id)
  end
  
  # Checks if this mentor is still enrolled in any other groups for this quarter and, if not, deletes the mentor
  # from the GroupResource for the associated quarter.
  def delete_from_group
    if mentor.mentor_quarters.for_quarter(quarter).empty?
      quarter.group_resource.delete_member(mentor.uw_net_id)
    end
  end
    
end
