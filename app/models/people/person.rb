class Person < CustomerScoped
  include Comparable

  has_many :event_attendances do
    def future_attending
      find :all, :joins => [:event], :conditions => ["events.date >= ? AND rsvp = ?", Time.now.midnight, true]
    end
		def non_visits
			find :all, :joins => [:event], :conditions => ["type IS NULL OR type = ?", "Event"]
		end
		def visits
			find :all, :joins => [:event], :conditions => ["type = ?", "Visit"]
		end
  end
  has_many :events, :through => :event_attendances do
    def future
      find :all, :conditions => ["date >= ?", Time.now.midnight]
    end
  end
  # has_many :how_did_you_hear_people
  # has_many :how_did_you_hear_options, :through => :how_did_you_hear_people
  has_and_belongs_to_many :how_did_you_hear_options
	belongs_to :highest_education_level, :class_name => "EducationLevel"
  
  has_many :users
  
  validates_presence_of :lastname, :firstname, :if => :validate_name?
  validates_uniqueness_of :survey_id, :allow_nil => true
  validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i, :allow_blank => true
  validates_format_of :email2, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i, :allow_blank => true
  validates_presence_of :firstname, :lastname, :email, :sex, :phone_mobile, :birthdate, :if => :validate_ready_to_rsvp?

  has_many :notes, :as => :notable, :conditions => "document_file_name IS NULL"
  has_many :documents, :as => :notable, :class_name => "Note", :conditions => "document_file_name IS NOT NULL AND title IS NOT NULL"

  has_many :training_completions
  has_many :trainings, :through => :training_completions, :source => :training

  has_and_belongs_to_many :programs

  mount_uploader :avatar, AvatarUploader
  
  after_create :generate_survey_id

  attr_accessor :validate_name
  attr_accessor :validate_ready_to_rsvp
  
  def validate_name?
    validate_name
  end

  def validate_ready_to_rsvp?
    validate_ready_to_rsvp
  end

  PERSON_RESOURCE_CACHE_LIFETIME = 1.day

  default_scope :order => "lastname, firstname, middlename", :conditions => { :customer_id => lambda {Customer.current_customer.id}.call }
  # default_scope lambda { |person| { :conditions => { :customer_id => Customer.current_customer.id } } }
  

  # Returns the actual person resource object. Specify +true+ as a parameter to fetch the "full" version
  # of the resource (only use this when more data is needed than the basics).
  def person_resource(full = false)
    q = full ? "#{reg_id}/full" : reg_id
    @person_resource ||= {}
    @person_resource[full.to_s] ||= person_resource? ? PersonResource.find(q) : nil
    @person_resource[full.to_s]
  end

  # Returns the person resource from the Student Web Service instead of from Person Web Service.
  def student_person_resource
    @student_person_resource ||= person_resource? ? StudentPersonResource.find(reg_id) : nil
  end
  
  def person_resource?
    !reg_id.nil?
  end
    
  # def [](attr_name)
  #   instance_eval(attr_name.to_s)
  # end
  
  # Returns the person's fullname in the form: Firstname Middlename Lastname
  # If we have a valid +person_resource+, then pass back +person_resource.DisplayName+ instead.
  def fullname(opt = {})
    options = { :middlename => true, :skip_update => false, :override_with_local => true }.merge(opt)
    if person_resource? && !options[:skip_update]
      update_resource_cache! rescue nil
      return display_name unless options[:override_with_local]
    end
    return display_name if firstname.blank? && lastname.blank?
    if options[:middlename]
      middlename_string = middlename.length == 1 ? " #{middlename.to_s.strip}." : " #{middlename.to_s.strip}" unless middlename.blank?
    end
    "#{firstname.to_s.strip}#{middlename_string.to_s} #{lastname.to_s.strip}"
  end
  
  def lastname_first(options = {})
    result = "#{lastname}, #{firstname}"
    result << middlename if options[:include_middlename] && !middlename.blank?
    result
  end
  
  def <=>(o)
    lastname_first <=> o.lastname_first
  end
  
  # Checks if this Person attended the specified event, and returns true if so.
  # Optionally, provide an EventType or EventGroup and this will return true if the Person attended
  # any events in that type or group.
  def attended?(event)
    return false unless event.is_a?(Event) || event.is_a?(EventGroup) || event.is_a?(EventType)
    
    if event.is_a?(Event)
      return false unless events.include?(event)
      event_attendances.find_by_event_id(event.id).attended?
    elsif event.is_a?(EventGroup)
      attendances = event_attendances.find(:all, :joins => [:event], :conditions => { :events => { :event_group_id => event.id }})
      return false if attendances.empty?
      attendances.collect(&:attended?).include?(true)
    elsif event.is_a?(EventType)
      attendances = event_attendances.find(:all, :joins => [:event], :conditions => { :events => { :event_type_id => event.id }})
      return false if attendances.empty?
      attendances.collect(&:attended?).include?(true)
    else
      false
    end
  end
  
  # Checks if this Person RSVP'd yes for the specified event, and returns true if so.
  def attending?(event)
    return false unless event.is_a?(Event)
    return false unless events.include?(event)
    event_attendances.find_by_event_id(event.id).rsvp?
  end

  # Checks if this Person has an attendance option set for the specified event, and returns the value if so.
  def attendance_option(event)
    return false unless event.is_a?(Event)
    return false unless events.include?(event)
    event_attendances.find_by_event_id(event.id).attendance_option
  end

  # Automatically capitalizes the first letter of +firstname+
  def firstname=(new_firstname)
    write_attribute(:firstname, uppercase_first_letter(new_firstname))
  end

  # Automatically capitalizes the first letter of +middlename+
  def middlename=(new_middlename)
    write_attribute(:middlename, uppercase_first_letter(new_middlename))
  end

  # Automatically capitalizes the first letter of +lastname+
  def lastname=(new_lastname)
    write_attribute(:lastname, uppercase_first_letter(new_lastname))
  end
  
  # Calculates the person's age. Returns nil if we don't know the birthdate.
  def age
    return nil unless birthdate
    dob = birthdate.is_a?(Date) ? birthdate : Date.parse(birthdate)
    now = Time.now.utc.to_date
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end

  # Pulls in contact info from the Person Web Service and updates our local cache if it hasn't been
  # updated in the amount of time specified in +PERSON_RESOURCE_CACHE_LIFETIME+. Pass +true+ to force a
  # refresh regardless of the time passed.
  # 
  # Returns +true+ if the cache was updated or +false+ if not.
  def update_resource_cache!(force = false)
    if person_resource? && (resource_cache_expired? || force)
      return true if self.update_attributes(
        :display_name   => person_resource.attributes["DisplayName"],
        :firstname      => person_resource.attributes["RegisteredFirstMiddleName"],
        :lastname       => person_resource.attributes["RegisteredSurname"],
        :uw_net_id      => person_resource.attributes["UWNetID"],
        :email          => person_resource.attributes["UWNetID"] + "@uw.edu",
        :birthdate      => (Date.parse(student_person_resource.attributes["BirthDate"]) rescue nil),
        :sex            => student_person_resource.attribute(:gender),
        :uw_student_no  => student_person_resource.attribute(:student_number).to_s.rjust(7, "0"),
        :resource_cache_updated_at => Time.now
      )
    end
    false
  end
  
  def resource_cache_expired?
    resource_cache_updated_at.nil? || Time.now - resource_cache_updated_at > PERSON_RESOURCE_CACHE_LIFETIME
  end
  
  def generate_survey_id(force = false)
    if read_attribute(:survey_id).blank? || force
      n = "A"
      n << id.to_s.rjust(5, "0")
      n << rand(9).to_s
      update_attribute(:survey_id, n)
      return n
    else
      return read_attribute(:survey_id)
    end
  end
  
  # Returns the survey_id or generates one if it's nil
  def survey_id
    generate_survey_id unless new_record?
  end
	
	# Returns the survey_id without generating it if it doesn't exist.
	def raw_survey_id
		read_attribute(:survey_id)
	end
  
  # Returns the class standing if possible.
  # def class_standing
  #   affil = person_resource.attributes["PersonAffiliations"].attributes["StudentPersonAffiliation"] rescue nil
  #   affil.attributes["StudentWhitePages"].attributes["Class"] rescue nil
  # end
  
  # Determines if this person can view the requested object. By default this returns false because we always override
  # this method in subclasses.
  def can_view?(object)
    false
  end
  
  # Determines if this person can edit the requested object. By default this returns false because we always override
  # this method in subclasses.
  def can_edit?(object)
    false
  end
  
  # People are considered "ready to RSVP" if certain aspects of their profile are complete. Generic "Person" resources
  # are _never_ considered ready to RSVP because they need to be classified as a more specific type of Person first.
  # 
  # For all people:
  # * name
  # * email
  # * gender
  # * phone number
  # * birthdate
  # 
  # For Students and Participants:
  # * affiliated programs
  #
  # For Volunteers:
  # * background check authorized at
  # * crimes against persons
  # * employer/organization
  # * t-shirt size
  def ready_to_rsvp?(event = nil)
    return false if self.class == Person
    self.validate_ready_to_rsvp = true
    self.valid?
  end
  
  def background_check_authorized
    !background_check_authorized_at.nil?
  end
  
  def background_check_authorized=(boolean)
    self.background_check_authorized_at = boolean == true || boolean == "1" ? Time.now : nil
  end
  
  # Strips all non digits from the phone number before storing it
  def phone_mobile=(new_number)
    write_attribute :phone_mobile, new_number.gsub(/[^0-9]/i, '')
  end

  # Strips all non digits from the phone number before storing it
  def phone_home=(new_number)
    write_attribute :phone_home, new_number.gsub(/[^0-9]/i, '')
  end

  # Strips all non digits from the phone number before storing it
  def phone_work=(new_number)
    write_attribute :phone_work, new_number.gsub(/[^0-9]/i, '')
  end
	
  # Strip out non-digit characters in annual_income if needed, like "$" or "," or other text.
  def annual_income=(new_amount)
    new_amount = new_amount.gsub(/[^0-9.]/i, '') unless new_amount.is_a?(Numeric)
    self.write_attribute(:annual_income, new_amount)
  end
  
  # Returns true if this person has completed the specified training
  def completed_training?(training)
    return false if training.nil?
    c = training_completions.find(:first, :conditions => { :training_id => training.id })
    c.nil? ? false : c.completed?
  end
  
  
  # Returns true if the text of the +background_check_result+ attribute 
  # includes either "OK" or "NO RECORD FOUND". This allows staff to allow a 
  # student to participate even if a conviction history has been found but 
  # the school has approved that student's participation. In that case, the
  # background check result text will include these details but also include 
  # to the text "OK".
  def passed_background_check?
    return false if background_check_result.nil?
    valid_length = Customer.current_customer.background_check_validity_length
    return true if valid_length < 0
    return false if (background_check_run_at.nil? || background_check_run_at < valid_length.days.ago)
    background_check_result.include?("OK") || background_check_result.include?("NO RECORD FOUND")
  end
  
  # Returns true if the +background_check_authorized_at+ is not nil but the person hasn't passed the background
  # check yet. This means that a staff person hasn't yet run the check and entered it into the system yet.
  def background_check_pending?
    !background_check_authorized_at.nil? && (!passed_background_check? && background_check_run_at.nil?)
  end
 
  # Returns true if the text of the +sex_offender_check_result+ attribute 
  # includes either "OK" or "NO RECORD FOUND". This allows staff to allow a 
  # student to participate even if a conviction history has been found but 
  # the school has approved that student's participation. In that case, the
  # sex offender check result text will include these details but also include 
  # to the text "OK". 
  def passed_sex_offender_check?
    return false if sex_offender_check_result.nil?
    valid_length = Customer.current_customer.background_check_validity_length
    return true if valid_length < 0
    return false if (sex_offender_check_run_at.nil? || sex_offender_check_run_at < valid_length.days.ago)
    sex_offender_check_result.include?("OK") || sex_offender_check_result.include?("NO RECORD FOUND")
  end
    
  # Returns true if a staff person hasn't yet run the check and entered it into the system.
  def sex_offender_check_pending?
    !background_check_authorized_at.nil? && (!passed_sex_offender_check? && sex_offender_check_run_at.nil?)
  end
  
  # Returns true if both SO and BG checks passed, false otherwise
  def passed_criminal_checks?
    passed_sex_offender_check? && passed_background_check?
  end
  
  # If both SO and criminal background checks were run, returns later of the two
  # dates on which the checks were run. Useful for displaying a single date
  # for when background checks were passed
  def criminal_checks_run_at
    if sex_offender_check_run_at && background_check_run_at
      [sex_offender_check_run_at, background_check_run_at].max
    else
      nil
    end
  end
  
  # Returns true if there are any responses "Yes" on the background check form from mentor signup.
  def has_background_check_form_responses?
    return true if crimes_against_persons_or_financial? || drug_related_crimes?
    return true if related_proceedings_crimes? || medicare_healthcare_crimes? || general_convictions?
    false
  end
  
  # Returns false by default. This method is overridden in subclasses.
  def current_lead_at
    []
  end
  
  # Returns false by default. This method is overridden in subclasses.
  def current_lead?
    false
  end
  
  # Returns true if this Person's first (or only) User record is an AnonymousUser. 
  # Anonymous users can never be admins.
  def is_anonymous_user?
    users.first.is_a?(AnonymousUser)
  end
  
  # Always returns false. By default, a person can never use a login token to login.
  # Override this method in subclasses to provide this functionality to certain models.
  def has_valid_login_token?
    false
  end
    
  protected
  
  # Uppercases the first letter of the string and does nothing else.
  def uppercase_first_letter(str)
    str[0..0].upcase + str[1..-1] rescue str
  end
  
end
