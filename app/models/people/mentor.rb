class Mentor < Person
  extend FriendlyId
  friendly_id :friendly_slug

  has_many :mentor_terms
  has_many :mentor_term_groups, through: :mentor_terms
  
  has_many :mentor_participants
  has_many :participants, through: :mentor_participants
	has_many :activity_logs
  
  validates_uniqueness_of :reg_id, allow_blank: true

  attr_accessor :validate_background_check_form, :validate_risk_form, :validate_conduct_form, :validate_driver_form

  validates_inclusion_of :crimes_against_persons_or_financial, :drug_related_crimes, :related_proceedings_crimes, :medicare_healthcare_crimes, :general_convictions, if: :validate_background_check_form, in: [true,false], message: "cannot be left blank"
  validates_presence_of :background_check_authorized_at, if: :validate_background_check_form

  validates_presence_of :risk_form_signed_at, :risk_form_signature, message: "cannot be left blank", if: :validate_risk_form
  
  validates_presence_of :conduct_form_signed_at, :conduct_form_signature, message: "cannot be left blank", if: :validate_conduct_form

  validates_presence_of :driver_form_signed_at, :driver_form_signature, message: "cannot be left blank", if: :validate_driver_form

  after_save :send_driver_email

  acts_as_xlsx

  def self.find_or_create_from_reg_id(reg_id)
    new_mentor = Mentor.find_or_initialize_by_reg_id(reg_id)
    new_mentor.validate_name = false
    new_mentor.update_resource_cache!(true)
    new_mentor
  end

  # Generates a slug for friendly_id to use using a UW NetID if it exists, or email handle otherwise.
  def friendly_slug
    uw_net_id.blank? ? email.to_s.split("@").first : uw_net_id
  end

  # Returns true if +passed_background_check?+ and +signed_risk_form?+ and +currently_enrolled?+ all return true, and
  # if has attended mentor workshop (if necessary)
  def passed_basics?
    (!Customer.require_background_checks? || (passed_background_check? && passed_sex_offender_check?)) && (!Customer.require_risk_form? || signed_risk_form?) && (!Customer.require_conduct_form? || signed_conduct_form?)&& currently_enrolled? && (!Customer.mentor_workshop_event_type || attended_mentor_workshop?) && (!Customer.require_parental_consent_for_minors? || (is_18? || parental_consent_on_file?))
  end

  # Returns a string detailing the steps needed for this mentor
  # to be ready to mentor
  def readiness_summary
    return "Ready to mentor" if passed_basics?
    summary = ""
    if Customer.require_risk_form?
      if !signed_risk_form?
        summary << "* Must sign risk form  "
      end
    end
    if Customer.require_parental_consent_for_minors?
      if !is_18?
        if !parental_consent_on_file?
          summary << "* Must require parental consent "
        end
      end
    end
        if Customer.require_conduct_form?
      if !signed_conduct_form?
        summary << "* Must sign conduct agreement  "
      end
    end
    if Customer.require_background_checks?
      if !passed_background_check?
        summary << "* Hasn't passed BG Check  "
      end
      if !passed_sex_offender_check?
        summary << "* Hasn't passed SO Check  "
      end
    end
    if !attended_mentor_workshop?
      summary << "* Must attend mentor workshop"
    end
    return summary
  end

  # Save common but expensive queries in a cache,
  # updated on save
  def update_filter_cache!
    super

    # Requires this to be called after mentor_term updates
    Customer.redis.hset(self.redis_key("filters"), "currently_enrolled", currently_enrolled?)
    
    # Requires this to be called after event_attendance updates
    Customer.redis.hset(self.redis_key("filters"), "attended_mentor_workshop", attended_mentor_workshop?) if Customer.mentor_workshop_event_type

    @filter_status = Customer.redis.hgetall(self.redis_key("filters"))
  end

  # Returns true if there is a valid date in the +risk_form_signed_at+ attribute and any value in the
  # +risk_form_signature+ attribute.
  def signed_risk_form?
    !risk_form_signed_at.nil? && !risk_form_signature.blank?
  end

  # Returns true if there is a valid date in the +conduct_form_signed_at+ attribute and any value in the
  # +conduct_form_signature+ attribute.
  def signed_conduct_form?
    !conduct_form_signed_at.nil? && !conduct_form_signature.blank?
  end

  def correct_login_token?(given_token)
    secure_compare_token(given_token)
  end

  def send_login_link(login_link)
    mandrill = Mandrill::API.new(MANDRILL_API_KEY)
    
    template_content = [
      {name: 'title', content: "An account has been created for you by #{Customer.name_label}."},
      {name: 'main_message', content: "#{Customer.name_label} is using DreamSIS.com to manage its program and keep track of student information. You can use the link below to login and setup your account. If you have any questions, please contact your program administrator."}
    ]
    message = {
      to: [{name: fullname, email: email }],
      global_merge_vars: [
        {name: "login_link", content: login_link}
      ],
      subject: "Your #{Customer.name_label} account on DreamSIS.com"
    }

    return mandrill.messages.send_template 'Account E-mail', template_content, message
    
  rescue Mandrill::Error => e
      puts "A mandrill error occurred: #{e.class} - #{e.message}"
      raise
  end

  # Returns true if the mentor is enrolled for the current term.
  def currently_enrolled?
    passes_filter?(:currently_enrolled) || !current_mentor_terms.empty?
  end

=begin
Returns whether the mentor is signed up for the correct sections
as layed out in the given term's course dependencies
  
MentorTermGroup.course_dependencies outline:
  
(Dept Abv) (Course Number)(Letter optional):<----------------------|
  never any: [(C.N.), (C.N.),..., (C.N.)]  <------| As many        | Repeat
  not currently: [(C.N.), (C.N.),..., (C.N.)]     | as             | as
  require: [(C.N.), (C.N.),..., (C.N.)]           | needed         | needed
  have taken one: [(C.N.), (C.N.),..., (C.N.)] <--|<---------------|

Sample:
  
EDUC 260:
  never any: [EDUC 360, EDUC 361]
  not currently: [EDUC 360]
  require: [EDUC 369]
EDUC 360:
  have taken one: [EDUC 260]
  not currently: [EDUC 260]
  require: [EDUC 369]
EDUC 361:
  require: [EDUC 369]
EDUC 361A:
  have taken one: [EDUC 360]
  not currently: [EDUC 260, EDUC 360]
EDUC 361B:
  require: [EDUC 260, EDUC 360]
EDUC 369:
  require: [EDUC 260, EDUC 360, EDUC 361]

--------------------------------------------------------------

Documentation for each filter:

 * Dept Abv: All caps department abbrevation, e.g., EDUC

 * Course Number: 3-digit course number for course, e.g., 360

 * Letter: Section letter (as stated above, this is optional). If a letter is used,
   the rules are valid for that section only

 Note: Valid combinations of the above include EDUC 360, EDUC 361A, etc. As you
       can see above, you can make a general listing for a course (see EDUC 361) and
       then give requirements for each section (see EDUC 361A and EDUC 361B).

 * never any: Lists course numbers a mentor can't have had before. It checks all
   past courses. If even just one of the courses listed has been had by the
   mentor, the function returns false.

 * not currently: Lists courses you can't be concurrently enrolled in with.
   If a mentor is enrolled in any of the list, returns false.

 * require: Lists a set of courses from which mentor must be currently enrolled in.
   If a mentor isn't signed up for any of the listed courses, returns false.

 * have taken one: Lists a set of courses from which a mentor must have been
   signed up for in the past. If the mentor hasn't taken any of the listed
   courses, returns false
 
=end

  def correct_sections? (term = Term.current_term)
    if !(mts = mentor_terms.for_term(term)).empty?
      current_groups = mts.collect(&:mentor_term_group)
      current_sections = current_groups.collect {|grp| grp.course_string }
      all_groups = self.mentor_terms.collect(&:mentor_term_group).flatten.compact.uniq
      prev_groups = all_groups.delete_if{|k,v| current_groups.include? k}
      prev_sections = prev_groups.collect {|grp| grp.course_string }
      yaml = term.course_dependencies
      return true if !yaml || yaml.blank?

      dependencies = YAML.load(yaml)
      correct = true
      dependencies.each do |dep, rules|
        if current_sections.any? { |cur_sec| cur_sec.include? dep }
          correct = check_dependency(current_sections, prev_sections, dep, rules)
        end
        return false if !correct
      end
      return correct
    else
      return false
    end
  end

  # Returns a string of the titles of current mentor term groups for this mentor.
  def current_mentor_term_groups_string
    return "no groups" if (cmtgs = current_mentor_term_groups).nil?
    cmtgs.collect(&:title).to_sentence
  end

  # "Current" mentor terms are defined as mentor terms from either the current term AND any term marked
  # as allowing signups. To limit this to a particular location, pass that as an option parameter.
  def current_mentor_terms(location = nil)
    terms = Term.allowing_signups.collect(&:id)
    terms << Term.current_term.id if Term.current_term
    terms = terms.flatten.uniq
    conditions = { mentor_term_groups: { term_id: terms }, deleted_at: nil }
    conditions[:mentor_term_groups][:location_id] = location.try(:id) if location
    mentor_terms.where(conditions).joins(:mentor_term_group)
  end
  
  # Returns the locations for each of the #current_mentor_term_groups.
  def current_locations
    current_mentor_term_groups.collect(&:location).flatten.uniq.compact
  end

  # Returns the mentor term groups associated with this mentor's current mentor terms
  def current_mentor_term_groups(location = nil)
    current_mentor_terms(location).collect(&:mentor_term_group)
  end

  # Returns the high school records for the high schools at which this mentor is a high school lead.
  def current_lead_at
    current_lead_mentor_terms.collect(&:location)
  end

  # Returns the mentor terms for which this mentor is a high school lead
  def current_lead_mentor_terms
    current_mentor_terms.select(&:lead?)
  end

  # Returns true if +current_lead_at+ is not empty.
  def current_lead?
    !current_lead_at.empty?
  end

  # Returns true if the mentor has attended an event in the "Mentor Workshop" type.
  def attended_mentor_workshop?
    return passes_filter?(:attended_mentor_workshop) unless passes_filter?(:attended_mentor_workshop).nil?
    
    return true if mentor_terms.collect(&:term).uniq.reject {|m| m == Term.current_term}.count > 0 rescue true
    !event_attendances.includes({ event: :event_type }).where({ attended: true, event_types: { name: "Mentor Workshop" }}).empty?
  end

  # Returns true if +van_driver_training_completed_at+ is not nil
  def driver_trained?
    !van_driver_training_completed_at.nil?
  end

  # Returns true if +driver_form_signature+ is not nil
  def signed_driver_form?
    !driver_form_signature.nil?
  end

  # Returns true if this user's +van_driver_training_completed_at+ is not null and the current customer
  # requiring mentors to complete a driver form implies the mentor has OK in +driver_form_remarks+ if they have
  # previous driving convictions. Additionally, if the current customer links to uw, checks if there is a
  # uwfs training date on file. Finally, checks if +van_driver_training_completed_at+ is less than
  # the number of days ago defined by the customer to be valid
  def valid_van_driver?
    return false if !van_driver_training_completed_at
    return false if van_driver_training_expired?

    (!Customer.require_driver_form? ||
            (driver_form_signature && (!has_previous_driving_convictions || driver_form_remarks["OK"]))) &&
    (!Customer.link_to_uw? || uwfs_training_date)
  end


  # Returns true if +van_driver_training_completed_at+ is nil
  # or there is a set validity length for the current customer
  # and the training has expired, false otherwise
  def van_driver_training_expired?
    return true if !van_driver_training_completed_at
    valid_length = Customer.driver_training_validity_length || 0
    return true unless valid_length > 0
    van_driver_training_completed_at < valid_length.days.ago
  end

  # Returns true if the +aliases+ attribute has anything other than blank, nil, "none", "n/a" or "no"
  def has_aliases?
    return false if aliases.blank? || aliases.nil?
    return false if aliases.downcase == "none" || aliases.downcase == "n/a" || aliases.downcase == "no"
    true
  end

  # Returns all mentors who have completed a van driver training (but may not have passed
  # other customer driving requirements) for the ActiveRecord term given if there is one, or
  # all such drivers if a term is not given
  def self.valid_van_drivers(term_id = nil, mtg_id = nil)
    if term_id
      conditions = {"mentor_term_groups.term_id" => term_id}
      if mtg_id
        conditions["mentor_term_groups.id"] = mtg_id
      end
      joins(:mentor_term_groups).where(conditions).where("van_driver_training_completed_at IS NOT NULL")
    else
      where.not(van_driver_training_completed_at: nil)
    end
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
      for mentor_term in current_mentor_terms
        return true if mentor_term.permissions_level == "any"
        return true if mentor_term.location_id == object.try(:id)
      end
    end
    false
  end

  # Determines the access level that this mentor has to certain objects.
  #
  # A mentor can edit a participant if:
  # * the participant is in the mentor's current list of mentees
  # * the participant is in the current cohort at a high school that the mentor attends
  # * the mentor is a current high school lead at that participant's high school
  #
  # Additionally, mentors can be assigned to a group which grants additional permissions.
  # See options at MentorTermGroup.PERMISSION_LEVELS for details.
  def can_edit?(object)
    if object.is_a?(Participant)
      return true if participants.include?(object)
      return true if object.new_record?
      
      for mentor_term in current_mentor_terms
        return true if mentor_term.permissions_level == "any"

        if mentor_term.location_id == object.try(:high_school_id)
          return true if mentor_term.lead?
          return true if mentor_term.permissions_level == "current_school_any_cohort"
          return true if mentor_term.permissions_level == "current_school_future_cohorts" && object.try(:grad_year) >= Participant.current_cohort
          return true if object.try(:grad_year) == Participant.current_cohort # this is the default choice
        end
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
      firstName: firstname.to_s.titlecase,
      lastName: lastname.to_s.titlecase,
      email: email,
      zipCode: (zip || 98105),
      allowVicariousLogin: true,
      dream: true
    })
    self.update_attribute(:college_mapper_id, @college_mapper_counselor.id)
    @college_mapper_counselor
  rescue ActiveResource::BadRequest => e
    logger.info { e.message }
    false
  end

  # Allows for dynamically created symbols to be sent to mentors,
  # specifically to generate excel columns for a given term
  def method_missing(method_name, *args)
    if m = method_name.to_s.match(/\Asection_summary_for_(.+)\Z/)
      section_summary Term.find(m[1])
    elsif m = method_name.to_s.match(/\Asection_status_for_(.+)\Z/)
      section_status Term.find(m[1])
    elsif m = method_name.to_s.match(/\Aevent_summary_for_(.+)\Z/)
      event_summary_for_term Term.find(m[1])
    elsif m = method_name.to_s.match(/\Aevent_count_for_(.+)\Z/)
      event_count_for_term Term.find(m[1])
    elsif m = method_name.to_s.match(/\Aenrollment_status_for_(.+)\Z/)
      enrollment_status_for_term Term.find(m[1])
    elsif m = method_name.to_s.match(/\Alocations_for_(.+)\Z/)
      locations_for_term Term.find(m[1])
    else
      super method_name, *args
    end
  end

  # Determines columns that are exported into xlsx packages for the given term
  def self.term_report_columns term_id
    columns = [:id, :firstname, :middlename, :lastname, :email, :uw_net_id,
      :uw_student_no, "enrollment_status_for_#{term_id}",  "section_status_for_#{term_id}",
      "locations_for_#{term_id}", "section_summary_for_#{term_id}", :previous_participant_id, 'is_18?',
      :eighteenth_birthday, "event_summary_for_#{term_id}", "event_count_for_#{term_id}",
      :terms_participated, :date_joined, "current_lead?", :readiness_summary,
      "valid_van_driver?", "driver_trained?", "signed_driver_form?", "signed_risk_form?",
      "signed_conduct_form?", "background_check_pending?", "passed_background_check?",
      "sex_offender_check_pending?", "passed_sex_offender_check?", "passed_criminal_checks?",
      "attended_mentor_workshop?"]
  end

  # Gives the locations associated with all MentorTerms for a given term
  def locations_for_term(term = Term.current_term)
    mentor_terms.for_term(term).collect do |mt|
      mt.try(:mentor_term_group).try(:location).try(:name)
    end.compact.sort.join(", ")
  end

  # Returns a date representing the first time a mentor was added to any
  # mentor term
  def date_joined
    if !(mt = mentor_terms).empty?
      mentor_terms.collect(&:created_at).compact.sort.first.to_date
    else
      nil
    end
  end

  # Returns the number of terms that this mentor has had an associated
  # MentorTerm
  def terms_participated
    mentor_terms.collect{|mt| mt.try(:mentor_term_group).try(:term)}.uniq.count
  end

  # Gives a count of the number of events, either RSVP'd or
  # attended, for a given term. Excludes mentor workshops, class
  # events, or events where an RSVP was on file, but the event
  # has passed (AKA a "no-show")
  def event_count_for_term(term = Term.current_term)
    es = event_summary_for_term(term)
    events = es.split("*, ")
    events.reject do |ev|
      ev["no-show"]
    end.count
  end

  # Returns a string representing EventAttendances for this
  # mentor for the given term, pairing title with attendance
  # status ("Attended", "no-show", or "RSVP'd"
  def event_summary_for_term(term = Term.current_term)
    attendances = event_attendances_for_term(term)
    sums = attendances.collect do |att|
      event = att.event
      status = if (att.attended)
                 "Attended"
               elsif(event.past?)
                 "no-show"
               else
                 "RSVP'd"
               end

      "#{event.name}:#{status}"
    end
    sums.join("*, ")
  end

  # Returns all event attendances for mentor for the given term.
  # excluding new mentor workshops, class events, and visits
  def event_attendances_for_term(term = Term.current_term)
    event_attendances.find(
      :all,
      joins: "LEFT OUTER JOIN events ON event_attendances.event_id = events.id
                 LEFT OUTER JOIN event_types ON events.event_type_id = event_types.id",
      conditions: ["events.date >= ?
      AND events.date <= ?
      AND (rsvp = ? OR attended = ?)
      AND (event_type_id IS NULL OR event_types.name != ?)
      AND events.name != ?
      AND events.type != 'Visit'",
      term.start_date, term.end_date, true, true, "Mentor Workshop", 'Class']
    )
  end

  # Returns true if this mentor is 18 years old, false otherwise
  def is_18?
    return nil unless birthdate
    Time.now.to_date >= eighteenth_birthday
  end

  # Returns a date representing this mentor's 18th birthday
  def eighteenth_birthday
    return nil unless birthdate
    birthdate + 18.years
  end

  # Returns either "Enrolled", "Volunteer", or "Enrolled/Volunteer"
  # depending on how this mentor registered for MentorTermGroups
  # for the given term
  def enrollment_status_for_term(term = Term.current_term)
    raise "Bad argument" if !term.is_a?(Term)
    mts = mentor_terms.for_term(term)
    return "Not Enrolled" if mts.empty?

    volunteers = mts.select(&:volunteer)
    status = []
    if volunteers.count < mts.count
      status << "Enrolled"
    end
    if volunteers.count > 0
      status << "Volunteer"
    end
    status.join("/")
  end

  # Returns a string with pairs of MentorTermGroup titles and
  # whether the associated MentorTerms are volunteer or enrollment
  # records, or "none" if there are no MentorTerms for the given
  # quarter
  def section_summary(term = Term.current_term)
    mts = mentor_terms.for_term(term).collect do |mt|
      "#{mt.title}:#{mt.volunteer ? 'Volunteer' : 'Enrolled'}"
    end
    if mts.empty?
      "none"
    else
      mts.join(',')
    end
  end

  # Returns a string representing whether or not this mentor
  # is signed up for the proper sections
  def section_status(term = Term.current_term)
    correct_sections?(term) ? "Correct" : "Incorrect sections"
  end
  
  protected

  def send_driver_email
    if Customer.send_driver_form_emails && van_driver_training_completed_at_changed?
      MentorMailer.driver(self).deliver
    end
  end

  # Handles the logic of course dependencies
  def check_dependency(current_sections, prev_sections, course, rules)
    correct = true
    if rules.include? "have taken one"
      valid = false
      prev_sections.each do |prev_s|
        valid ||= rules["have taken one"].any? {|section| prev_s.include?(section)}
      end
      correct &&= valid
    end
    if rules.include? "require"
      valid = false
      current_sections.each do |cur_s|
        valid ||= rules["require"].any? {|section| cur_s.include?(section)}
      end
      correct &&= valid
    end
    if rules.include? "not currently"
      current_sections.each do |cur_s|
        correct &&= !rules["not currently"].any? {|section| cur_s.include?(section)}
      end
      correct &&= valid
    end
    if rules.include? "never any"
      prev_sections.each do |prev_s|
        correct &&= !rules["never any"].any? {|section| prev_s.include?(section)}
      end
    end
    return correct
  end

end
