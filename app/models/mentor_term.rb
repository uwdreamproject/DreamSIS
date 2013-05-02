class MentorTerm < ActiveRecord::Base
  belongs_to :mentor_term_group, :counter_cache => true
  belongs_to :mentor
  
  validates_presence_of :mentor_id, :mentor_term_group_id
  validates_uniqueness_of :mentor_id, :scope => :mentor_term_group_id, :message => "is already a member of this group"

  delegate :term, :term_id, :location, :title, :location_id, :to => :mentor_term_group
  delegate :fullname, :email, :reg_id, :participants, :mentor_participants, :to => :mentor
  
  default_scope :order => "people.lastname, people.firstname", :joins => :mentor
  
  # after_create :add_to_group
  
  def destroy
    update_attribute :deleted_at, Time.now
    MentorTermGroup.decrement_counter(:mentor_terms_count, mentor_term_group.id)
    # delete_from_group
  end
  
  def deleted?
    !deleted_at.nil?
  end

  attr_accessor :new_participant_id
  
  def new_participant_id=(new_participant_id)
    mentor.participants << Participant.find(new_participant_id) rescue false
  end
  
  # Adds this mentor to the GroupResource for the associated Term. This method doesn't check if the
  # mentor is already a part of the group or not because the UW Groups Service will simply ignore the duplicate.
  def add_to_group
    term.group_resource.add_member(mentor.uw_net_id)
  end
  
  # Checks if this mentor is still enrolled in any other groups for this term and, if not, deletes the mentor
  # from the GroupResource for the associated term.
  def delete_from_group
    if mentor.mentor_terms.for_term(term).empty?
      term.group_resource.delete_member(mentor.uw_net_id)
    end
  end
    
end
