class Person < ActiveRecord::Base
  include Comparable
  has_many :event_attendances do
    def future_attending
      find :all, :joins => [:event], :conditions => ["events.date >= ? AND rsvp = ?", Time.now.midnight, true]
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
  
  has_many :users
  
  validates_presence_of :lastname, :firstname, :if => :validate_name?
  validates_uniqueness_of :survey_id, :allow_nil => true

  has_many :notes, :as => :notable

  after_create :generate_survey_id

  attr_accessor :validate_name
  
  def validate_name?
    validate_name
  end

  PERSON_RESOURCE_CACHE_LIFETIME = 1.day

  default_scope :order => "lastname, firstname, middlename"

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
  def fullname(options = { :middlename => true })
    if person_resource?
      update_resource_cache! rescue nil
      return display_name
    end
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
  
  protected
  
  # Uppercases the first letter of the string and does nothing else.
  def uppercase_first_letter(str)
    str[0..0].upcase + str[1..-1] rescue str
  end
  
end