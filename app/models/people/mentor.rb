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
	has_many :activity_logs
  
  validates_uniqueness_of :reg_id, :allow_blank => true

  attr_accessor :validate_background_check_form, :validate_risk_form, :validate_conduct_form, :validate_driver_form

  validates_inclusion_of :crimes_against_persons_or_financial, :drug_related_crimes, :related_proceedings_crimes, :medicare_healthcare_crimes, :general_convictions, :if => :validate_background_check_form, :in => [true,false], :message => "cannot be left blank"
  validates_presence_of :background_check_authorized_at, :if => :validate_background_check_form

  validates_presence_of :risk_form_signed_at, :risk_form_signature, :message => "cannot be left blank", :if => :validate_risk_form
  
  validates_presence_of :conduct_form_signed_at, :conduct_form_signature, :message => "cannot be left blank", :if => :validate_conduct_form

  validates_presence_of :driver_form_signed_at, :driver_form_signature, :message => "cannot be left blank", :if => :validate_driver_form

  after_save :send_driver_email

  def self.find_or_create_from_reg_id(reg_id)
    new_mentor = Mentor.find_or_initialize_by_reg_id(reg_id)
    new_mentor.validate_name = false
    new_mentor.update_resource_cache!(true)
    new_mentor
  end
  
  # Returns true if +passed_background_check?+ and +signed_risk_form?+ and +currently_enrolled?+ all return true, and
  # if has attended mentor workshop (if necessary)
  def passed_basics?
    (!Customer.require_background_checks? || (passed_background_check? && passed_sex_offender_check?)) && (!Customer.require_risk_form? || signed_risk_form?) && (!Customer.require_conduct_form? || signed_conduct_form?)&& currently_enrolled? && (!Customer.mentor_workshop_event_type || attended_mentor_workshop?)
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
  
  # This mentor has a valid login token if there is a value in +login_token+ and the timestamp in
  # +login_token_expires_at+ is in the future.
  def has_valid_login_token?
    return false if login_token.blank? || login_token_expires_at.nil?
    return true if login_token_expires_at.future?
    false
  end
  
  # Generates a new random login token and stores it in the record, along with an expiry date of
  # 1 week from now.
  def generate_login_token!
    new_login_token = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{rand(10e200).to_s(36)}--")
    update_attributes(:login_token => new_login_token, :login_token_expires_at => 1.week.from_now)
    new_login_token
  end
  
  def invalidate_login_token!
    update_attributes(:login_token => nil, :login_token_expires_at => nil)
  end
  
  def send_login_link(login_link)
    mandrill = Mandrill::API.new(MANDRILL_API_KEY)
    
    template_content = [
      {:name => 'title', :content => "An account has been created for you by #{Customer.name_label}."},
      {:name => 'main_message', :content => "#{Customer.name_label} is using DreamSIS.com to manage its program and keep track of student information. You can use the link below to login and setup your account. If you have any questions, please contact your program administrator."}
    ]
    message = {
      :to => [{:name => fullname, :email => email }],
      :global_merge_vars => [
        {:name => "login_link", :content => login_link}
      ],
      :subject => "Your #{Customer.name_label} account on DreamSIS.com"
    }

    return mandrill.messages.send_template 'Account E-mail', template_content, message
    
  rescue Mandrill::Error => e
      puts "A mandrill error occurred: #{e.class} - #{e.message}"
      raise    
  end
    
  # Returns true if the mentor is enrolled for the current term.
  def currently_enrolled?
    !current_mentor_term_groups.empty?
  end

=begin
Returns whether the mentor is signed up for the correct sections
as layed out in the current term's course dependencies
  
MentorTermGroup.course_dependencies outline:
  
(Dept Abv) (Course Number)(Letter optional):<--------------------|
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

  def correct_sections?
    return true #if (current_lead? || (self.users.first.admin? rescue false)) **Section checking currently disabled
    if currently_enrolled?
      current_groups = self.current_mentor_term_groups.select{|m| m.term.id == Term.allowing_signups.first.id}.collect(&:mentor_term_group)
      current_sections = current_groups.collect {|grp| grp.course_string }
      all_groups = self.mentor_term_groups
      prev_groups = all_groups.delete_if{|k,v| current_groups.include? k}
      prev_sections = prev_groups.collect {|grp| grp.course_string }
      yaml = current_groups.first.term.course_dependencies
      dependencies = 0
      if yaml
        dependencies = YAML.load(yaml)
      else
        return true
      end
      correct = true
      dependencies.each do |dep, rules|
        if current_sections.any? { |cur_sec| cur_sec.include? dep }
          correct = check_dependency(current_sections, prev_sections, dep, rules) 
        end
        return correct if !correct
      end
    return correct
    else
      return false
    end
  end
  
  # Returns a string of the titles of current mentor term groups for this mentor.
  def current_mentor_term_groups_string
    return "no groups" if current_mentor_term_groups.nil?
    current_mentor_term_groups.collect(&:title).to_sentence
  end
  
  # "Current" mentor term groups are defined as groups from either the current term AND any term marked
  # as allowing signups. To limit this to a particular location, pass that as an option parameter.
  def current_mentor_term_groups(location = nil)
    terms = Term.allowing_signups.collect(&:id)
    terms << Term.current_term.id if Term.current_term
    terms = terms.flatten.uniq
    conditions = { :mentor_term_groups => { :term_id => terms }, :deleted_at => nil }
    conditions[:mentor_term_groups][:location_id] = location.try(:id) if location
    mentor_terms.find :all, :joins => [:mentor_term_group], :conditions => conditions
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
    return true if mentor_terms.collect(&:term).uniq.reject {|m| m == Term.current_term}.count > 0 rescue true
    !event_attendances.find(:all, 
                            :include => { :event => :event_type }, 
                            :conditions => { :attended => true, :event_types => { :name => "Mentor Workshop" }}
                            ).empty?
  end
  
  # Returns true if this user's +van_driver_training_completed_at+ is not null and the current customer
  # requiring mentors to complete a driver form implies the mentor has OK in +driver_form_remarks+ if they have
  # previous driving convictions
  def valid_van_driver?
    van_driver_training_completed_at && (!Customer.require_driver_form? ||
        (driver_form_signature && (!has_previous_driving_convictions || driver_form_remarks["OK"])))
  end
  
  # Returns true if the +aliases+ attribute has anything other than blank, nil, "none", "n/a" or "no"
  def has_aliases?
    return false if aliases.blank? || aliases.nil?
    return false if aliases.downcase == "none" || aliases.downcase == "n/a" || aliases.downcase == "no"
    true
  end
  
  # Returns all mentors who are valid van drivers.
  def self.valid_van_drivers
    find(:all, :conditions => ["van_driver_training_completed_at IS NOT NULL"])
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
      for mentor_term in current_mentor_term_groups
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
      
      for mentor_term in current_mentor_term_groups
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
  
  protected

  def send_driver_email
    if Customer.send_driver_form_emails && van_driver_training_completed_at_changed?
      MentorMailer.deliver_driver!(self)
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
