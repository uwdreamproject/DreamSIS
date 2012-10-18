class Event < ActiveRecord::Base
  include Comparable
  has_many :attendees, :class_name => "EventAttendance" do
    def all(audience = nil)
      audience = audience.class if audience.is_a?(Person)
      conditions = {}
      conditions.merge!({ :people => { :type => audience.to_s.classify }}) if audience
      find(:all, :conditions => conditions, :joins => :person, :order => "lastname, firstname")
    end
    def rsvpd(audience = nil)
      audience = audience.class if audience.is_a?(Person)
      conditions = { :rsvp => true }
      conditions.merge!({ :people => { :type => audience.to_s.classify }}) if audience
      find(:all, :conditions => conditions, :joins => :person, :order => "lastname, firstname")
    end
    def attended(audience = nil)
      audience = audience.class if audience.is_a?(Person)
      conditions = { :attended => true }
      conditions.merge!({ :people => { :type => audience.to_s.classify }}) if audience
      find(:all, :conditions => conditions, :joins => :person, :order => "lastname, firstname")
    end
  end
  has_many :people, :through => :attendees
  belongs_to :location
  belongs_to :event_type
  belongs_to :event_group
  belongs_to :event_coordinator, :class_name => "Person", :foreign_key => "event_coordinator_id"
  
  has_many :shifts, :class_name => "EventShift" do
    def for(audience)
      return [] if audience.nil? || !%w(Volunteer Mentor).include?(audience.to_s)
      find(:all, :conditions => { "show_for_#{h(audience.to_s.pluralize)}" => true })
    end
  end
  
  validates_presence_of :date
  
  default_scope :order => "date, start_time"
  
  # Returns the number of attended
  def attended_count
    attendees.attended.size
  end
  
  # Returns the number of RSVP'd (for the given audience, if provided)
  def rsvpd_count(audience)
    attendees.rsvpd(audience).size
  end

  # Return the capacity for this event. If no audience person or type is provided, return the overall capacity
  # for the event (defined by the generic +capacity+ attribute). Otherwise, return the capacity for this audience.
  def capacity(person_or_type = nil)
    overall_capacity = read_attribute(:capacity)
    return overall_capacity if person_or_type.nil?

    klass = person_or_type.is_a?(Person) ? person_or_type.class : person_or_type
    if klass == Student || klass == Participant
      custom_capacity = student_capacity
    elsif klass == Volunteer
      custom_capacity = volunteer_capacity
    elsif klass == Mentor
      custom_capacity = mentor_capacity
    end    
    (custom_capacity.nil? || custom_capacity <= 0) ? overall_capacity : custom_capacity
  end


  # Returns true if the number of RSVP'd attendees is greater than or equal to the capacity defined.
  # If capacity is 0 or nil, this method always returns false.
  def full?(person_or_type = nil)
    return false if capacity(person_or_type).nil? || capacity(person_or_type) <= 0
    attendees.rsvpd(person_or_type).size >= capacity(person_or_type)
  end
  
  # How full is this event in percentage.
  def percent_full(person_or_type = nil)
    return false if capacity(person_or_type).nil? || capacity(person_or_type) <= 0
    attendees.rsvpd(person_or_type).size.to_f / capacity(person_or_type).to_f * 100
  end
  
  def <=>(o)
    date <=> o.date
  end

  # Returns true if there's no Location assigned to this event.
  def program_wide?
    location_id.nil?
  end
  
  def past?
    date < Date.today
  end
  
  def short_title
    short_date = date.strftime('%b %d')
    if name.blank?
      "#{short_date}"
    else
      "#{name} (#{short_date})"
    end
  end
  
  # If this event is attached to a location, use that location name. Otherwise use location_text. If both
  # exist, concatenate them together with a comma. This is useful for displaying something like "Foster
  # High School, Room 223".
  def location_string
    if location
      str = location.name
      str += ", " + location_text unless location_text.blank?
    else
      str = location_text
    end
    str
  end
  
  # Returns true if shifts have been defined for this event.
  def has_shifts?(audience)
    audience ? !shifts.for(audience).empty? : !shifts.empty?
  end
  
  # Returns true if training is required for this event's EventGroup for the specified person or person type.
  def training_required?(person_or_type)
    return false if event_group.nil?
    klass = person_or_type.is_a?(Person) ? person_or_type.class : person_or_type.constantize
    return false if event_group[klass.to_s.downcase + "_training_optional"]
    !event_group.training_for(person_or_type).nil?
  end

  # Returns the training for this event's EventGroup for the specified person or person type.
  def training_for(person_or_type)
    return false if event_group.nil?
    klass = person_or_type.is_a?(Person) ? person_or_type.class : person_or_type.constantize
    if klass == Volunteer
      event_group.volunteer_training
    elsif klass == Mentor
      event_group.mentor_training
    else
      nil
    end
  end
  
  # See EventGroup#description for details.
  def description(person_or_type = nil)
    generic_description = read_attribute(:description)
    return generic_description if person_or_type.nil?
    klass = person_or_type.is_a?(Person) ? person_or_type.class : person_or_type
    if klass == Student || klass == Participant
      custom_description = student_description
    elsif klass == Volunteer
      custom_description = volunteer_description
    elsif klass == Mentor
      custom_description = mentor_description
    end
    custom_description.blank? ? generic_description : custom_description
  end
  
  # Convenience method for +time_detail(:time_only => true)+
  def time_only
  time_detail(:time_only => true)
  end

  # Returns a human-readable bit of text describing the start and end times of this event, as follows:
  # 
  # * If no +end_time+ is defined, then simply state the date and start time: <tt>(date) at (start_time)</tt>
  # * If an +end_time+ is defined and the dates for both the start and end are the same: <tt>(date) from (start_time) to (end_time)</tt>
  # * If +end_time+ is on a different date than +start_time+: <tt>(start_date) at (start_time) to (end_date) at (end_time)</tt>
  # 
  # *Options*
  # 
  # Allowable options include:
  # 
  # * +use_words+: Use words like "from" and "at" instead of a hyphen or a space. Defaults to true.
  # * +date_format+: Format to use for date portions. Defaults to +date_with_day_of_week+.
  # * +time_format+: Format to use for time portions. Defaults to +time12+.
  # * +time_only+: Don't show the date, just the time(s).
  # * +date_only+: Don't show the times, just the date.
  # * +use_relative_dates+: Use "today" and "tomorrow" where applicable. Defaults to +true+.
  def time_detail(options = {})
    default_options = {
     :use_words => true,
     :date_format => :date_with_day_of_week,
     :time_format => :time12,
     :use_relative_dates => true
    }
    options = default_options.merge(options)
    separator = options[:use_words] ? { :to => " to", :from => " from", :at => " at" } : { :to => " -", :from => "", :at => "" }
    _start_date = date.to_date.to_s(options[:date_format]).strip
    _start_date = "Today" if date.to_date == Time.now.to_date && options[:use_relative_dates]
    _start_date = "Tomorrow" if date.to_date == 1.day.from_now.to_date && options[:use_relative_dates]
    _start_time = start_time.to_time.to_s(options[:time_format]).strip if start_time
    _end_date = end_time.to_date.to_s(options[:date_format]).strip if end_time
    _end_date = "today" if end_time && end_time.to_date == Time.now.to_date && options[:use_relative_dates]
    _end_date = "tomorrow" if end_time && end_time.to_date == 1.day.from_now.to_date && options[:use_relative_dates]
    _end_time = end_time.to_time.to_s(options[:time_format]).strip if end_time
    return "Time TBA" if options[:time_only] && time_tba?
    return "#{_start_date}" if (options[:date_only] && (end_time.blank? || start_time.to_date == end_time.to_date)) || start_time.blank? || time_tba?
    return "#{_start_time}" if options[:time_only] && !end_time
    return "#{_start_time}#{separator[:to]} #{_end_time}" if options[:time_only] && start_time.to_date == end_time.to_date
    return "#{_start_date}#{separator[:at]} #{_start_time}" if start_time && end_time.nil?
    return "#{_start_date}#{separator[:from]} #{_start_time}#{separator[:to]} #{_end_time}" if start_time.to_date == end_time.to_date
    return "#{_start_date}#{separator[:at]} #{_start_time}#{separator[:to]} #{_end_date}#{separator[:at]} #{_end_time}"
  end

end
