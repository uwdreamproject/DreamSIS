class MentorTerm < ActiveRecord::Base
  belongs_to :mentor_term_group, counter_cache: true
  belongs_to :mentor
  
  validates_presence_of :mentor_id, :mentor_term_group_id
  validates_uniqueness_of :mentor_id, scope: :mentor_term_group_id, message: "is already a member of this group"

  delegate :term, :term_id, :location, :title, :location_id, :permissions_level, to: :mentor_term_group
  delegate :fullname, :email, :reg_id, :participants, :mentor_participants, to: :mentor
  
  default_scope { where(deleted_at: nil).order("people.lastname, people.firstname").joins(:mentor).readonly(false) }
  scope :deleted, -> { where.not(deleted_at: nil) }
  scope :for_term, ->(term_id) { joins(:mentor_term_group).where(mentor_term_groups: { term_id: (term_id.is_a?(Term) ? term_id.id : term_id) }, deleted_at: nil) }
  scope :lead, -> { where(lead: true) }
  
  after_save :update_filter_cache
  after_destroy :update_filter_cache
  
  acts_as_taggable
  
  def destroy
    update_attribute :deleted_at, Time.now
    MentorTermGroup.decrement_counter(:mentor_terms_count, mentor_term_group.id)
    # delete_from_group
  end
  
  def deleted?
    !deleted_at.nil?
  end

  # Updates the mentor filter cache
  def update_filter_cache
    mentor.save
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
