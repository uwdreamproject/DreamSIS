class Event < ActiveRecord::Base
  include Comparable
  extend SimpleCalendar
  has_calendar :attribute => :start_datetime

  has_many :attendees, :inverse_of => :event, :class_name => "EventAttendance"
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
  
  include MultitenantProxyable
  acts_as_proxyable parent: :event_group, dependents: [:location], parent_direction: :forward

  def proxyable_attributes
    excluded = %w[id created_at updated_at event_group_id event_type_id 
                  earliest_grade_level latest_grade_level location_id event_coordinator_id]
    attributes.except(*excluded)
  end  
  
  belongs_to :earliest_grade_level, :class_name => "GradeLevel", :primary_key => 'level', :foreign_key => 'earliest_grade_level_level'
  belongs_to :latest_grade_level, :class_name => "GradeLevel", :primary_key => 'level', :foreign_key => 'latest_grade_level_level'
  
  validates_presence_of :date
  
  default_scope order("date, start_time")
  scope :visits, where(:type => "Visit")
  scope :past, lambda { where("date <= ?", Date.today) }

  # Allows overwriting of type in controller, default is [+id+, +type+]
  def self.attributes_protected_by_default
    ["id"]
  end

  # Returns the number of attended
  def attended_count
    attendees.attended.size
  end
  
  # Returns the number of RSVP'd (for the given audience, if provided)
  def rsvpd_count(audience)
    attendees.rsvpd(audience).size
  end
  
  # For now, only Visit type events can have attendance options.
  def attendance_options
    []
  end
  
  def visit?
    false
  end

  # Return the capacity for this event. If no audience person or type is provided, return the overall capacity
  # for the event (defined by the generic +capacity+ attribute). Otherwise, return the capacity for this audience.
  def capacity(person_or_type = nil)
    attribute_for_audience_with_generic(:capacity, person_or_type) do |cust_cap|
      cust_cap && cust_cap > 0
    end
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
  
  # Returns a string of the valid grade levels for this filter.
  def grade_levels_list_string(html = true)
    return "" unless !earliest_grade_level.nil? || !latest_grade_level.nil?
    delimiter = html ? "&ndash;" : "-"
    [earliest_grade_level_level, latest_grade_level_level].join(delimiter)
  end
  
  def display_for?(participant)
    return false if participant.grade.nil?
    valid = true
    valid = participant.grade >= earliest_grade_level_level unless earliest_grade_level_level.nil?
    valid = participant.grade <= latest_grade_level_level unless latest_grade_level_level.nil?
    return valid
  end
  
  # Returns all Events that are relevant to the requested GradeLevel.
  def self.for_grade_level(level)
    find(:all, :conditions => ["? >= earliest_grade_level_level AND ? <= latest_grade_level_level", level, level])
  end
  
  def past?
    date < Date.today
  end
  
  def this_week?
    date.try(:this_week?)
  end
  
  def short_title
    short_date = date.strftime('%b %d')
    if name.blank?
      "#{short_date}"
    else
      "#{name} (#{short_date})"
    end
  end
  
  # Combines the date and start_time into a DateTime object that marks the start of the event.
  def start_datetime
    d = date
    t = start_time || Time.new.midnight
    DateTime.new(d.year, d.month, d.day, t.hour, t.min, t.sec)
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
  
  # Returns true if the supplied User or Person has admin access to this event. This includes:
  # 
  # * system-wide admins
  # * current mentor group leads
  # * event coordinator
  # * any event attendee with the +admin+ flag set
  def allows_admin_access_for?(user_or_person)
    if user_or_person.is_a?(User)
      return true if user_or_person.admin?
      person = user_or_person.person
    elsif user_or_person.is_a?(Person)
      person = user_or_person
    end
    return false if person.nil?
    return true if person.current_lead?
    return true if event_coordinator == person
    return true if person.event_attendances.find_by_event_id(id).try(:admin?)
    return false
  end
  
  # Returns true if training is required for this event's EventGroup for the specified person or person type.
  def training_required?(person_or_type)
    return false if event_group.nil?
    aud = Event.process_audience(person_or_type)
    return false if event_group[aud.to_s.downcase + "_training_optional"]
    !event_group.training_for(person_or_type).nil?
  end

  # Returns the training for this event's EventGroup for the specified person or person type.
  def training_for(person_or_type)
    return false if event_group.nil?
    aud = Event.process_audience(person_or_type)
    return nil unless %i(Volunteer Mentor).include? aud
    attribute_for_audience(:training, aud)
  end
  
  # See EventGroup#description for details.
  def description(person_or_type = nil)
    attribute_for_audience_with_generic(:description, person_or_type)
  end

  # See EventGroup#description for details.
  def start_time(person_or_type = nil)
    attribute_for_audience_with_generic(:start_time, person_or_type)
  end

  # See EventGroup#description for details.
  def end_time(person_or_type = nil)
    attribute_for_audience_with_generic(:end_time, person_or_type)
  end
  
  # Returns true if there is an audience-specific time for the specified audience that is different from the generic event times.
  def time_is_audience_specific?(person_or_type = nil)
    start_time(person_or_type) != start_time || end_time(person_or_type) != end_time
  end
  
  # Convenience method for +time_detail(:time_only => true)+
  def time_only(person_or_type = nil)
    time_detail(:time_only => true, :audience => person_or_type)
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
  # * +audience+: Pass a person object or subclass of Person to use audience-specific times (if they exist).
  def time_detail(options = {})
    default_options = {
     :use_words => true,
     :date_format => :date_with_day_of_week,
     :time_format => :time12,
     :use_relative_dates => true,
     :audience => nil
    }
    options = default_options.merge(options)
    audience = options[:audience]
    separator = options[:use_words] ? { :to => " to", :from => " from", :at => " at" } : { :to => " -", :from => "", :at => "" }
    _start_date = date.to_date.to_s(options[:date_format]).strip
    _start_date = "Today" if date.to_date == Time.now.to_date && options[:use_relative_dates]
    _start_date = "Tomorrow" if date.to_date == 1.day.from_now.to_date && options[:use_relative_dates]
    _start_time = start_time(audience).to_time.to_s(options[:time_format]).strip if start_time(audience)
    _end_date = end_time(audience).to_date.to_s(options[:date_format]).strip if end_time(audience)
    _end_date = "today" if end_time(audience) && end_time(audience).to_date == Time.now.to_date && options[:use_relative_dates]
    _end_date = "tomorrow" if end_time(audience) && end_time(audience).to_date == 1.day.from_now.to_date && options[:use_relative_dates]
    _end_time = end_time(audience).to_time.to_s(options[:time_format]).strip if end_time(audience)
    return "Time TBA" if options[:time_only] && time_tba?
    return "#{_start_date}" if (options[:date_only] && (end_time(audience).blank? || start_time(audience).to_date == end_time(audience).to_date)) || start_time(audience).blank? || time_tba?
    return "#{_start_time}" if options[:time_only] && !end_time(audience)
    return "#{_start_time}#{separator[:to]} #{_end_time}" if options[:time_only] && start_time(audience).to_date == end_time(audience).to_date
    return "#{_start_date}#{separator[:at]} #{_start_time}" if start_time(audience) && end_time(audience).nil?
    return "#{_start_date}#{separator[:from]} #{_start_time}#{separator[:to]} #{_end_time}" if start_time(audience).to_date == end_time(audience).to_date
    return "#{_start_date}#{separator[:at]} #{_start_time}#{separator[:to]} #{_end_date}#{separator[:at]} #{_end_time}"
  end

  # Returns whether or not it is too close to the event to cancel RSVPs
  # for the given audience, if it was set by the +event_group+
  def rsvps_disabled?(person_or_type)
    return false unless event_group
    hours_prior = event_group.hours_prior_disable_cancel(person_or_type)
    return false if hours_prior.blank?
    ((start_datetime.to_time - Time.now) / 1.hour) <= hours_prior
  end

  # Takes one argument for which we attempt to determine the associated
  # auidience: one of Mentor, Volunteer, Student, or Participant
  #   * A string or symbol matching one of the above audiences
  #     (case-insensitive)
  #   * An ActiveRecord object of one of the above 4 types
  #   * One of the 4 above classes as a constant e.g. `Mentor`
  #
  # Raises ArgumentError on nil, as checks for nil audience should
  # be handled by the caller before invoking this method. Will
  # also raise ArgumentError if person_or_type cannot be resolved
  # to an audience.
  #
  # Returns a symbol representing the audience, e.g. `:Mentor`
  def self.process_audience(person_or_type)
    unless person_or_type.is_a?(Symbol)
      person_or_type = if person_or_type.is_a?(Person)
                         person_or_type.class.to_s
                       elsif person_or_type.is_a?(String)
                         person_or_type
                       elsif person_or_type.is_a?(Class)
                         person_or_type.to_s
                       else
                         raise ArgumentError, "Cannot parse audience", caller
                       end

      person_or_type = person_or_type.to_sym
    end

    person_or_type = person_or_type.capitalize
    unless %i(Volunteer Mentor Student Participant).include? person_or_type
      raise ArgumentError, "Invalid audience type", caller
    end

    person_or_type
  end

  protected

  # Helper methods for returning attributes prefixed by audience

  # Use this if there is a generic, non-audience attribute
  # which is the default.
  #
  # If a block is passed, calls that block
  # on the retireved audience-specific attribute and uses
  # the result of that call to validate the custom attribute.
  #
  # If a block is not passed, returns the generic attribute if
  # the custom attribute is `blank?`
  def attribute_for_audience_with_generic(attr, person_or_type)
    generic_attribute = read_attribute(attr)
    return generic_attribute if person_or_type.nil?
    aud = Event.process_audience(person_or_type)
    custom_attribute = attribute_for_audience(attr, aud)
    valid = block_given? ? yield(custom_attribute) : !custom_attribute.blank?
    valid ? custom_attribute : generic_attribute
  end

  def attribute_for_audience(attr,  audience)
    return read_attribute(attr) if audience.nil?
    audience = Event.process_audience(audience)
    audience = :Student if audience == :Participant
    read_attribute(audience.to_s.downcase + "_" + attr.to_s)
  end
end

