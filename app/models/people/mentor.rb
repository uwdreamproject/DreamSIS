class Mentor < Person
  has_many :mentor_terms, :conditions => { :deleted_at => nil } do
    def for_term(term_id)
      term_id = term_id.id if term_id.is_a?(Term)
      find :all, :joins => [:mentor_term_group], :conditions => { :mentor_term_groups => { :term_id => term_id }, :deleted_at => nil }
    end
  end
  has_many :mentor_term_groups, :through => :mentor_terms
  
  has_many :mentor_participants, :conditions => { :deleted_at => nil }
  has_many :participants, :through => :mentor_participants
  
  validates_uniqueness_of :reg_id, :allow_blank => true

  attr_accessor :validate_background_check_form, :validate_risk_form

  validates_inclusion_of :crimes_against_persons_or_financial, :drug_related_crimes, :related_proceedings_crimes, :medicare_healthcare_crimes, :general_convictions, :if => :validate_background_check_form, :in => [true,false], :message => "cannot be left blank"
  validates_presence_of :background_check_authorized_at, :if => :validate_background_check_form

  validates_presence_of :risk_form_signed_at, :risk_form_signature, :message => "cannot be left blank", :if => :validate_risk_form
  
  def self.find_or_create_from_reg_id(reg_id)
    new_mentor = Mentor.find_or_initialize_by_reg_id(reg_id)
    new_mentor.validate_name = false
    new_mentor.update_resource_cache!(true)
    new_mentor
  end
  
  # Returns true if +passed_background_check?+ and +signed_risk_form?+ both return true.
  def passed_basics?
    passed_background_check? && signed_risk_form? && currently_enrolled?
  end
    
  # Returns true if there is a valid date in the +risk_form_signed_at+ attribute and any value in the 
  # +risk_form_signature+ attribute.
  def signed_risk_form?
    !risk_form_signed_at.nil? && !risk_form_signature.blank?
  end
  
  # Returns true if the mentor is enrolled for the current term.
  def currently_enrolled?
    !current_mentor_term_groups.empty?
  end
  
  # Returns a string of the titles of current mentor term groups for this mentor.
  def current_mentor_term_groups_string
    return "no groups" if current_mentor_term_groups.nil?
    current_mentor_term_groups.collect(&:title).to_sentence
  end
  
  # "Current" mentor term groups are defined as groups from either the current term AND any term marked
  # as allowing signups.
  def current_mentor_term_groups
    terms = Term.allowing_signups.collect(&:id)
    terms << Term.current_term.id if Term.current_term
    terms = terms.flatten.uniq
    mentor_terms.find :all, :joins => [:mentor_term_group], 
      :conditions => { :mentor_term_groups => { :term_id => terms }, :deleted_at => nil }
  end
  
  # Returns the high school records for the high schools at which this mentor is a high school lead.
  def current_lead_at
    current_mentor_term_groups.select(&:lead?).collect(&:location)
  end
  
  # Returns true if +current_lead_at+ is not empty.
  def current_lead?
    !current_lead_at.empty?
  end
  
  # Returns true if the mentor has attended an event in the "Mentor Workshop" type.
  def attended_mentor_workshop?
    !event_attendances.find(:all, 
                            :include => { :event => :event_type }, 
                            :conditions => { :attended => true, :event_types => { :name => "Mentor Workshop" }}
                            ).empty?
  end
  
  # Returns true if this user's +van_driver_training_completed_at+ is within the last two years.
  def valid_van_driver?
    return false if van_driver_training_completed_at.nil?
    van_driver_training_completed_at > 2.years.ago
  end
  
  # Returns true if the +aliases+ attribute has anything other than blank, nil, "none", "n/a" or "no"
  def has_aliases?
    return false if aliases.blank? || aliases.nil?
    return false if aliases.downcase == "none" || aliases.downcase == "n/a" || aliases.downcase == "no"
    true
  end
  
  # Returns all mentors who are valid van drivers.
  def self.valid_van_drivers
    find(:all, :conditions => ["van_driver_training_completed_at > ?", 2.years.ago])
  end
  
  # Returns true if there's a non-blank value in +huksy_card_rfid+
  def husky_card_registered?
    !husky_card_rfid.blank?
  end
  
  # Determines what objects this mentor can view.
  # 
  # * A mentor can view a participant if they can edit it (See #can_edit?) or they are a current lead at any location.
  # * A mentor can view a high school if they are currently enrolled there.
  def can_view?(object)
    if object.is_a?(Participant)
      return true if current_lead?
      return can_edit?(object)
    elsif object.is_a?(Location)
      return current_mentor_term_groups.collect(&:location_id).include?(object.try(:id))
    end
    false
  end
  
  # Determines the access level that this mentor has to certain objects.
  # 
  # A mentor can edit a participant if:
  # * the participant is in the mentor's current list of mentees
  # * the participant is in the current cohort at a high school that the mentor attends
  # * the mentor is a current high school lead at that participant's high school
  def can_edit?(object)
    if object.is_a?(Participant)
      return true if participants.include?(object)
      if current_mentor_term_groups.collect(&:location_id).include?(object.try(:high_school_id))
        return true if current_lead_at.collect(&:id).include?(object.try(:high_school_id))
        return true if object.try(:grad_year) == Participant.current_cohort
      end
    end
    false
  end
  
  # Used to generate UNIQID for MPR surveys. To de-identify the survey results, we strip out
  # any personally-identifiable info (name, email, uwnetid) and replace that with a uniqid that
  # can be used to compare responses from previous surveys to new surveys. The uniqid is a SHA1 digest
  # of string "--UW--<netid>--", where <netid> is the user's UW NetID.
  def self.survey_uniqid(netid)
    Digest::SHA1.hexdigest("--UW--#{netid}--")
  end
  
  # Returns the CollegeMapperCounselor record for this individual if we have a college_mapper_id stored.
  # By default, if the record doesn't exist, we create it. You can override that by passing +false+ for
  # +create_if_nil+.
  def college_mapper_counselor(create_if_nil = true)
    if !self.college_mapper_id
      return create_college_mapper_counselor if create_if_nil
      return nil
    end
    @college_mapper_counselor ||= CollegeMapperCounselor.find(self.college_mapper_id)
  end

  # Creates a CollegeMapperCounselor record for this mentor and stores the CollegeMapper user ID in the
  # +college_mapper_id+ attribute. Returns +false+ if the account couldn't be created.
  def create_college_mapper_counselor
    @college_mapper_counselor = CollegeMapperCounselor.create({
      :firstName => firstname.to_s.titlecase,
      :lastName => lastname.to_s.titlecase,
      :email => email,
      :zipCode => (zip || 98105),
      :allowVicariousLogin => true,
      :dream => true
    })
    self.update_attribute(:college_mapper_id, @college_mapper_counselor.id)
    @college_mapper_counselor
  rescue ActiveResource::BadRequest => e
    logger.info { e.message }
    false
  end
  
end