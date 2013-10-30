class MentorParticipant < ActiveRecord::Base

  belongs_to :mentor
  belongs_to :participant
  
  validates_presence_of :mentor_id, :participant_id
  validates_uniqueness_of :mentor_id, :scope => :participant_id

  default_scope :order => "people.lastname, people.firstname", :joins => :participant
  
  after_save :update_college_mapper_association, :if => :college_mapper_student_exists?

  after_save :update_filter_cache
  after_destroy :update_filter_cache

  # Updates the participant filter cache
  def update_filter_cache
    participant.save
  end
  
  def destroy
    update_attribute :deleted_at, Time.now
    # MentorTermGroup.decrement_counter(:mentor_terms_count, mentor_term_group.id)
  end
  
  def deleted?
    !deleted_at.nil?
  end
  
  def college_mapper_student_exists?
    !participant.try(:college_mapper_id).nil?
  end
  
  # Returns the CollegeMapperAssociation record for this individual if we have a college_mapper_id stored.
  # By default, if the record doesn't exist, we create it. You can override that by passing +false+ for
  # +create_if_nil+.
  def college_mapper_association(create_if_nil = true)
    if !self.college_mapper_id
      return create_college_mapper_association if create_if_nil
      return nil
    end
    @college_mapper_association ||= CollegeMapperAssociation.find(self.college_mapper_id, :params => { :account_type => "students", :user_id => participant.college_mapper_student.try(:id) })
  end

  # Creates a CollegeMapperAssociation record for this participant and stores the CollegeMapper user ID in the
  # +college_mapper_id+ attribute. Returns +false+ if the account couldn't be created.
  def create_college_mapper_association
    return nil unless college_mapper_student_exists?
    @college_mapper_association = CollegeMapperAssociation.create({
      :studentId => participant.college_mapper_student.try(:id),
      :counselorId => mentor.college_mapper_counselor.try(:id)
    })
    self.update_attribute(:college_mapper_id, @college_mapper_association.id)
    @college_mapper_association
  rescue ActiveResource::BadRequest => e
    logger.info { e.message }
    false
  end

  def update_college_mapper_association
    return nil unless college_mapper_student_exists?
    if deleted? && self.college_mapper_id
      CollegeMapperAssociation.delete(self.college_mapper_id, :params => { :account_type => "students", :user_id => participant.college_mapper_student.try(:id) })
    elsif !college_mapper_id
      college_mapper_association(true)
    end
  rescue
    return
  end

end
