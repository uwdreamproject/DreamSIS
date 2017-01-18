class Participant < Person
  belongs_to :high_school
  has_many :college_applications
  has_many :scholarship_applications
  belongs_to :mother_education_level, class_name: "EducationLevel"
  belongs_to :father_education_level, class_name: "EducationLevel"
  belongs_to :family_income_level, class_name: "IncomeLevel"
  belongs_to :participant_group, counter_cache: true

  has_many :mentor_participants
  has_many :former_mentor_participants, -> { MentorParticipant.deleted }, class_name: "MentorParticipant"
	has_many :mentors, through: :mentor_participants
  has_many :parents, foreign_key: :child_id
  has_many :test_scores
  has_many :college_enrollments
  has_many :college_degrees
  has_many :fafsas, class_name: "PersonFafsa", foreign_key: :person_id
  has_many :financial_aid_packages

  validates_presence_of :birthdate, :high_school_id, if: :validate_ready_to_rsvp?

  attr_accessor :override_binder_date, :override_fafsa_date, :override_wasfa_date, :create_college_mapper_student_after_save, :link_to_current_user_after_save
  
  scope :in_cohort, ->(grad_year) { where(grad_year: grad_year) }
  scope :in_high_school, ->(high_school_id) { where(high_school_id: high_school_id) }
  scope :active, -> { where(["inactive IS NULL OR inactive = ?", false]) }
  scope :target, -> { where(["not_target_participant IS NULL OR not_target_participant = ?", false]) }
  scope :attending_college, ->(college_id) { where(college_attending_id: college_id) }
  scope :assigned_to_mentor, ->(mentor_id) { joins(:mentor_participants).where(mentor_participants: { mentor_id: mentor_id }) }

  # after_save :college_mapper_student, if: :create_college_mapper_student_after_save?
  after_create :link_to_current_user, if: :link_to_current_user_after_save?
  before_save :adjust_postsecondary_plan_to_match_college_attending

	POSTSECONDARY_GOAL_OPTIONS = [
    "2-year to 4-year transfer",
    "Gap year",
		"Vocational school",
		"Military service",
		"Job",
		"Not attend college",
		"Earn GED",
		"Don't know"
	]
  
  # Stores the categories for Participant ObjectFilters. The key should match the dom_id
  # of the category, and is also the key that gets displayed in the database.
  FILTER_CATEGORIES = {
    :"-general" => "General",
		contact: "Contact Information",
		college_applications: "Colleges",
		scholarship_applications: "Financial",
		parents: "Parents/Contacts",
		test_scores: "Tests",
		college_enrollments: "College Enrollment",
		college_degrees: "College Degrees",
		mentors: "Mentors",
		events: "Events",
		paperwork: "Paperwork",
		documents: "Documents",
		notes: "Notes"
  }
  
  # Stores the possible ways that participant lists can be dynamically displayed.
  ReportTypes = {
    basics: "Basics",
    college_applications: "College Applications",
    test_score_summaries: "Test Scores",
    rosters: "Roster",
    parents: "Parents & Contacts",
    attendance_summaries: "Attendance",
    financial_aid_packages: "Financial Aid",
    college_stages: "College Pipeline"
  }

  # Stores the types of exports available for participants (might be different from ReportTypes).
  ExportTypes = {
    basics: "Basics",
    college_applications: "College Applications",
    test_score_summaries: "Test Scores",
    parents: "Parents & Contacts",
    attendance_summaries: "Attendance",
    financial_aid_packages: "Financial Aid",
  }

  # Returns true if there is a value in the signature
  def completed_intake_form?
    !intake_form_signature.blank?
  end
  
  def validate_name?
    true
  end
    
  def link_to_current_user_after_save?
    link_to_current_user_after_save == true || link_to_current_user_after_save == "1"
  end
  
  # Returns an array of unique graudation years
  def self.cohorts
    Participant.pluck(:grad_year).uniq.compact.sort.reverse
  end
  
  # Returns the grad_year of the currently-active cohort:
  #
  # * if the current term is Winter, return current year
  # * if the current term is Summer, Autumn, or Spring, return current_year + 1
  def self.current_cohort
    q = Term.current_term || Term.allowing_signups.try(:first) || Term.last
    return q.end_date.year if q.quarter_code.nil? # For year-long terms
    q.quarter_code == 1 ? Time.now.year : Time.now.year + 1
  end
  
  # Returns all Filter objects that list Participant as the object_class
  def self.object_filters
    @object_filters ||= {}
    @object_filters[Customer.current_customer.url_shortcut] ||= ObjectFilter.where(object_class: "Participant")
  end
  
  # Takes an array of filter conditions and returns an ActiveRecord::Relation for
  # the intersection of those conditions in the filter cache. You can specify
  # direct redis keys ("ObjectFilter:6:pass") or short form ("6:pass").
  def self.intersect(filter_selections)
    return all if filter_selections.empty?
    keys = filter_selections.map{ |s| s.count(":") < 2 ? "ObjectFilter:" + s : s }
    Participant.where(id: Customer.redis.sinter(keys))
  end

  def method_missing(method_name, *args)
    if m = method_name.to_s.match(/\Afafsa_(\d{4})_(.+)\Z/)
      fafsa(m[1]).send m[2], *args
    else
      super(method_name, *args)
    end
  end

  # Determines what objects this particpant can view.
  #
  # * A participant can only view themselves
  def can_view?(object)
    if object.is_a?(Participant)
      return true if object.try(:id) == id
    end
  end
  
  def respond_to?(method_sym, include_private = false)
    if method_sym.to_s =~ /\Afafsa_(\d{4})_(.+)\Z/
      true
    else
      super
    end
  end
	
  # Tries to find duplicate records based on name and high school. Pass an array of participant data straight from your params
  # hash. Second parameter is a limit on the number of records to return (defaults to 50).
  def self.possible_duplicates(data, limit = 50)
    Participant.where(["firstname LIKE ? AND lastname LIKE ?", "#{data[:firstname]}%", "#{data[:lastname]}%"]).limit(limit)
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
    ethnicities << "latino" if latino?
    ethnicities << "african" if african?
    ethnicities << "african_american" if african_american?
    ethnicities << "american_indian" if american_indian?
    ethnicities << "asian" if asian?
    ethnicities << "asian_american" if asian_american?
    ethnicities << "pacific_islander" if pacific_islander?
    ethnicities << "caucasian" if caucasian?
    ethnicities << "middle_eastern" if middle_eastern?
    ethnicities << "pacific_islander" if pacific_islander?
    ethnicities << ethnicity_details if !ethnicity_details.blank? && options[:include_details]
    return ethnicities if separator.nil?
    ethnicities.join(separator)
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
  
  def fafsa(year = Time.now.year)
    fafsas.find_or_initialize_by(year: year)
  end
  
  def fafsa(year = Time.now.year)
    fafsas.find_or_initialize_by(year: year)
  end

  # Returns the Institution or College record for this Participant based on "college_attending_id",
  # which represents the school the person is _planning_ to attend.
  def college_attending
    return nil unless college_attending_id
    Institution.find(college_attending_id)
  end
  alias :college_planning_to_attend :college_attending
  
  # Returns the CollegeEnrollment representing where the student is _currently attending_,
  # based on the current enrollment validity period set in CollegeEnrollment.
  def current_college_enrollment
    return nil if college_enrollments.empty?
    @current_college_enrollment ||= college_enrollments.reorder("began_on DESC").where(
      ["began_on > ?", CollegeEnrollment::CURRENT_ENROLLMENT_VALIDITY_PERIOD.ago]
    ).first
  end
  
  # Returns true if +current_college_enrollment+ is not nil.
  def currently_college_enrolled?
    !current_college_enrollment.nil?
  end
  
  # Returns the name of the currently enrolled college, if it exists.
  def current_college_name
    current_college_enrollment.try(:name)
  end
  
  # Returns true if +college_degrees+ is not empty.
  def earned_college_degree?
    !college_degrees.empty?
  end
  alias :graduated_college? :earned_college_degree?
  
  # Returns the name(s) of the colleges from which this person earned a degree.
  # If there are multiple degrees, this method returns all of the names joined with a comma.
  def alma_mater_names
    college_degrees.reorder("graduated_on ASC").collect(&:name).join(", ")
  end
  
  # Returns the CollegeEnrollment representing where the student _most recently attended_, based on the
  # CollegeEnrollment record for this student that may or may not include an end date.
  # This is probably a better method to use when displaying a student's "current" college
  # because it's a bit more lenient in the lookup.
  def latest_college_enrollment
    return nil if college_enrollments.empty?
    college_enrollments.reorder("began_on DESC").first
  end

	# Automatically unsets +postsecondary_plan+ if +college_attending_id+ is changed.
	def adjust_postsecondary_plan_to_match_college_attending
		if college_attending_id_changed? && !college_attending_id.nil?
			self.postsecondary_plan = college_attending.try(:iclevel_description)
		elsif postsecondary_plan_changed? && !postsecondary_plan.blank?
			self.college_attending_id = nil
		end
	end

  # Calculates the current grade based on grad_year.
  def grade
    return nil unless grad_year
    academic_year_offset = 1 if Time.now.month > 6
    @grade = Time.now.year - grad_year + academic_year_offset.to_i + 12
    @grade
  end
  
  # Uses TestScore#score_comparison to return a hash of test score comparisons for the the specified
  # type of test.
  def test_scores_comparison(test_type)
    @score_comparison ||= {}
    @score_comparison[test_type] ||= TestScore.score_comparison(self, test_type)
  end
	
	# Returns the Visits that happened during the week of the requested date at this student's HighSchool.
	def visits_during_week(date = Date.today)
		start_date = date.beginning_of_week
		end_date = date.end_of_week
		Visit.where(["date >= ? AND date <= ? AND location_id = ?", start_date, end_date, high_school_id])
	end
	
	# Determines the columns that are exported into xlsx pacakages. Includes most model columns
	# plus some extra attributes defined by methods. Also includes all ObjectFilters.
	def self.xlsx_columns
		columns = []
		columns << self.column_names.map { |c| c = c.to_sym }
		columns << [:high_school_name, :raw_survey_id, :college_planning_to_attend_name,
                :currently_college_enrolled?, :current_college_name, :graduated_college?, :alma_mater_names,
								:family_income_level_title, :program_titles, :assigned_mentor_names,
								:participant_group_title, :multiracial?,
                "fafsa_#{Time.now.year}_fafsa_submitted_at", "fafsa_#{Time.now.year}_wasfa_submitted_at",
                "fafsa_#{Time.now.year}_not_applicable"]
		columns << Participant.object_filters.collect { |f| "Filter: #{f.title}" }
		remove_columns = [:filter_cache, :login_token, :login_token_expires_at, :customer_id,
								:avatar, :college_mapper_id, :avatar_image_url, :college_mapper_id, :husky_card_rfid,
								:survey_id, :relationship_to_child, :occupation,	:annual_income,	:needs_interpreter,
								:meeting_availability, :child_id, :fafsa_submitted_date, :fafsa_not_applicable]
		columns = columns.flatten - remove_columns
    f1 = columns.index :firstname
    columns.delete :firstname
    columns.insert(f1, :formal_firstname)
	end
	
	def college_attending_name
		college_attending.try(:name)
	end
  alias :college_planning_to_attend_name :college_attending_name
	
	def high_school_name
		high_school.try(:name)
	end
	
	def family_income_level_title
		family_income_level.try(:title)
	end
	
	def program_titles
		programs.collect(&:title).join(", ")
	end
	
	def assigned_mentor_names
		mentors.collect(&:fullname).join(", ")
	end
	
	def participant_group_title
		participant_group.try(:title)
	end
  
  def search_result
    super.merge(cohort: [high_school_name.to_s, grad_year.to_s].join(" "))
  end
  
  def update_groupings_cache!
    commit_group_result! 'cohort', grad_year
    commit_group_result! 'high_school', high_school_id
    commit_group_result! 'participant_group', participant_group_id if participant_group_id
  end
  
  # Returns a collection of EventAttendance objects to be displayed on a Participant's detail page.
  # Starting with all existing event_attendances, this method adds in Event objects with a grade level range that
  # matches this Participant's grade level, if a grade level is assigned. If an EventAttendance record
  # does not exist for these Events, a new record is initialized and included (but not saved).
  def relevant_event_attendances
    return @eas if @eas
    @eas = event_attendances.non_visits
    return @eas if grad_year.nil? # If no grade level, then we're done
    event_ids = @eas.collect(&:event_id)
    Event.for_grade_level(grade).each do |event|
      @eas << event_attendances.new(event_id: event.id) unless event_ids.include?(event.id)
    end
    @eas
  end
  
  # Returns the _n_ most recent events that are open for Participants. Defaults to 5.
  def self.recent_events(number = 5)
    @recent_events ||= Event.past.where(show_for_participants: true).reverse_order.limit(number)
  end
  
  # Creates a ParticipantMentor link between this Participant and the Mentor that is the current user.
  # This will only succeed if the current user (from User#current_user) is a Mentor person.
  def link_to_current_user
    if User.current_user && User.current_user.try(:person).is_a?(Mentor)
      mentors << User.current_user.try(:person)
    end
  end
  
  def new_mentor_id=(mentor_id)
    mentors << Mentor.find(mentor_id)
  rescue ActiveRecord::RecordInvalid
    errors.add(:new_mentor_id, "has already been added to this participant")
  end
  
  # Returns the objects that have a child relationship to this object:
  #
  # * college_applications
  # * scholarship_applications
  # * parents
  # * test_scores
  # * college_enrollments
  # * college_degrees
  # * participant_mentors
  # * event_attendances
  def child_objects
    collections = %w[college_applications scholarship_applications parents test_scores
                     college_enrollments college_degrees mentor_participants event_attendances
                     notes
                   ]
    child_objects = []
    for collection in collections
      child_objects << self.instance_eval(collection)
    end
    
    child_objects.flatten.compact
  end

  def has_valid_login_token?
    return false unless Customer.allow_participant_login?
    super
  end

  def correct_login_token?(given_token)
    secure_compare_token(given_token)
  end

  def send_login_link(login_link)
  #   mandrill = Mandrill::API.new(MANDRILL_API_KEY)
  #
  #   template_content = [
  #     {name: 'title', content: "An account has been created for you by #{Customer.name_label}."},
  #     {name: 'main_message', content: "#{Customer.name_label} is using DreamSIS.com to manage its program and keep track of student information. You can use the link below to login and setup your account. If you have any questions, please contact your #{Customer.mentor_label} or #{Customer.lead_label}."}
  #   ]
  #   message = {
  #     to: [{name: fullname, email: email }],
  #     global_merge_vars: [
  #       {name: "login_link", content: login_link}
  #     ],
  #     subject: "Your #{Customer.name_label} account on DreamSIS.com"
  #   }
  #
  #   return mandrill.messages.send_template 'Account E-mail', template_content, message
  #
  # rescue Mandrill::Error => e
  #     puts "A mandrill error occurred: #{e.class} - #{e.message}"
  #     raise
    raise NotImplementedError.new("send_login_link")
  end

end
