class Participant < Person
  belongs_to :high_school
  has_many :college_applications
  has_many :scholarship_applications
  belongs_to :mother_education_level, :class_name => "EducationLevel"
  belongs_to :father_education_level, :class_name => "EducationLevel"
  belongs_to :family_income_level, :class_name => "IncomeLevel"
  belongs_to :participant_group, :counter_cache => true

  has_many :mentor_participants
  has_many :mentors, :through => :mentor_participants
  
  validates_presence_of :birthdate, :high_school_id, :if => :validate_ready_to_rsvp?

  attr_accessor :override_binder_date, :override_fafsa_date, :create_college_mapper_student_after_save, :link_to_current_user_after_save
  
  named_scope :in_cohort, lambda {|grad_year| {:conditions => { :grad_year => grad_year }}}
  named_scope :in_high_school, lambda {|high_school_id| {:conditions => { :high_school_id => high_school_id }}}
  named_scope :active, :conditions => ["inactive IS NULL OR inactive = ?", false]

  after_save :college_mapper_student, :if => :create_college_mapper_student_after_save?
  after_create :link_to_current_user, :if => :link_to_current_user_after_save?

  def validate_name?
    true
  end
  
  def create_college_mapper_student_after_save?
    create_college_mapper_student_after_save || self.high_school.try(:enable_college_mapper_integration?)
  end
  
  def link_to_current_user_after_save?
    link_to_current_user_after_save || link_to_current_user_after_save == "1"
  end
  
  # Returns an array of unique graudation years
  def self.cohorts
    Participant.find(:all, :select => "DISTINCT grad_year").collect(&:grad_year).compact.sort.reverse
  end
  
  # Returns the grad_year of the currently-active cohort:
  # 
  # * if the current quarter is Winter, return current year
  # * if the current quarter is Summer, Autumn, or Spring, return current_year + 1
  def self.current_cohort
    q = Quarter.current_quarter || Quarter.allowing_signups.try(:first) || Quarter.last
    q.quarter_code == 1 ? Time.now.year : Time.now.year + 1
  end
  
  # Returns all Filter objects that list Participant as the object_class
  def self.object_filters
    ObjectFilter.find_all_by_object_class("Participant")
  end
  
  # Tries to find duplicate records based on name and high school. Pass an array of participant data straight from your params
  # hash. Second parameter is a limit on the number of records to return (defaults to 50).
  def self.possible_duplicates(data, limit = 50)
    Participant.find(:all, 
                    :conditions => ["firstname LIKE ? AND lastname LIKE ?", "#{data[:firstname]}%", "#{data[:lastname]}%"],
                    :limit => limit)
  end
  
  # Returns true if multiple ethnicity checkboxes were checked
  def multiracial?
    ethnicities.size > 1
  end
  
  # Returns true if none of the ethnicity checkboxes are checked, even if ethnicity_details contains a value.
  def no_ethnicity_response?
    ethnicities.empty?
  end
  
  # Returns a list of all the ethnicities for this participant. If a separator is provided, then returns a
  # concatenated string, otherwise just an array. Pass an +include_details+ option to also include the +ethnicity_details+
  # field.
  def ethnicities(separator = nil, options = {})
    ethnicities = []
    ethnicities << "hispanic" if hispanic?
    ethnicities << "african_american" if african_american?
    ethnicities << "american_indian" if american_indian?
    ethnicities << "asian" if asian?
    ethnicities << "pacific_islander" if pacific_islander?
    ethnicities << "caucasian" if caucasian?
    ethnicities << ethnicity_details if !ethnicity_details.blank? && options[:include_details]
    return ethnicities if separator.nil?
    ethnicities.join(separator)
  end

  # Returns true if there is a value in the +fafsa_submitted_date+ field.
  def submitted_fafsa?
    !fafsa_submitted_date.nil?
  end
  
  # Automatically updates the +binder_date+ to Time.now if the value is true or to nil if the value is false.
  def received_binder=(binder_boolean)
    write_attribute(:received_binder, binder_boolean)
    if received_binder?
      write_attribute(:binder_date, override_binder_date || Time.now)
    else
      write_attribute(:binder_date, nil)
    end
  end
  
  def submitted_fafsa=(fafsa_boolean)
    if fafsa_boolean == true || fafsa_boolean == "true"
      write_attribute(:fafsa_submitted_date, override_fafsa_date || Time.now)
    else
      write_attribute(:fafsa_submitted_date, nil)
    end
  end
  
  # Returns true if there is a value in the fafsa_submitted_date field
  def submitted_fafsa?
    !fafsa_submitted_date.nil?
  end

  # Returns the Institution or College record for this Participant.
  def college_attending
    return nil unless college_attending_id
    Institution.find(college_attending_id)
  end

  # Calculates the current grade based on grad_year. If over 12, this method will always return 12.
  def grade
    return nil unless grad_year
    academic_year_offset = 1 if Time.now.month > 6
    @grade = Time.now.year - grad_year + academic_year_offset.to_i + 12
    @grade > 12 ? 12 : @grade
  end

  # Returns the CollegeMapperStudent record for this individual if we have a college_mapper_id stored.
  # By default, if the record doesn't exist, we create it. You can override that by passing +false+ for
  # +create_if_nil+. This method will also update the college list in DreamSIS to match the student's
  # college list on CollegeMapper. Override that by passing +false+ for +update_college_list+.
  def college_mapper_student(create_if_nil = true, update_college_list = true)
    if !self.college_mapper_id
      return create_college_mapper_student if create_if_nil
      return nil
    end
    @college_mapper_student ||= CollegeMapperStudent.find(self.college_mapper_id)
    update_college_list_from_college_mapper if update_college_list
    @college_mapper_student
  end

  # Creates a CollegeMapperStudent record for this participant and stores the CollegeMapper user ID in the
  # +college_mapper_id+ attribute. Returns +false+ if the account couldn't be created.
  def create_college_mapper_student
    @college_mapper_student = CollegeMapperStudent.create({
      :firstName => firstname.to_s.titlecase,
      :lastName => lastname.to_s.titlecase,
      :email => email,
      :zipCode => (zip || 98105),
      :grade => grade,
      :gender => (sex == "F" ? "female" : "male"),
      :dream => true,
      :youthforce => self.high_school.try(:name).include?("YouthForce")
    })
    self.update_attribute(:college_mapper_id, @college_mapper_student.id)
    @college_mapper_student
  rescue ActiveResource::BadRequest => e
    logger.info { e.message }
    false
  end
  
  # Fetches the college list for this student from CollegeMapper and updates the collection of CollegeApplications
  # to match.
  def update_college_list_from_college_mapper
    college_mapper_colleges = college_mapper_student(true, false).colleges
    college_ids = college_mapper_colleges.collect{|c| c.collegeId.to_i }
    
    # Delete colleges that no longer exist in CollegeMapper (if institution_id > 0)
    for college_application in college_applications
      college_application.destroy if college_application.institution_id > 0 && !college_ids.include?(college_application.institution_id.to_i)
    end

    # Create new colleges that exist in CollegeMapper
    for college in college_mapper_colleges
      college_applications.find_or_create_by_institution_id(college.collegeId) unless college.removed?
    end
  end
  
  # Creates a ParticipantMentor link between this Participant and the Mentor that is the current user.
  # This will only succeed if the current user (from User#current_user) is a Mentor person.
  def link_to_current_user
    if User.current_user && User.current_user.try(:person).is_a?(Mentor)
      mentors << User.current_user.try(:person)
    end
  end
  
end
