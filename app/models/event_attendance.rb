class EventAttendance < ActiveRecord::Base
  belongs_to :event, :inverse_of => :attendees
  belongs_to :person, :touch => true
  belongs_to :event_shift

  validates_presence_of :person_id, :event_id
  validates_uniqueness_of :person_id, :scope => :event_id, :message => "already has an event attendance record for this event"
  validates_format_of :audience, :with => /(\AMentor\z)|(\AVolunteer\z)|(\AParticipant\z)|(\AStudent\z)/

  validates :attendance_option, inclusion: { in: lambda{|option| Customer.visit_attendance_options_array } }, :allow_blank => true

  validate :validate_event_shift
  
  validate :validate_rsvp_limits, :if => :enforce_rsvp_limits?

  validate :validate_rsvps_not_disabled
  
  delegate :fullname, :firstname, :lastname, :email, :to => :person
  delegate :has_shifts?, :date, :start_time, :end_time, :to => :event, :allow_nil => true
  
  after_save :send_email
  
  alias :shift :event_shift
  attr_accessor :enforce_rsvp_limits
  
  after_save :update_filter_cache
  after_destroy :update_filter_cache
  before_save :replace_blank_attendance_option

  # default_scope :joins => :person, :order => "lastname, firstname"
  scope :rsvpd, where(:rsvp => true)
  scope :attended, where(:attended => true)
  
  acts_as_xlsx

  include MultitenantProxyable
  acts_as_proxyable parent: :event, dependents: [:person, :event_shift], parent_direction: :reverse

  def proxyable_attributes
    excluded = %w[id created_at updated_at admin person_id event_id event_shift_id]
    new_attributes = attributes.except(*excluded)
  end

  # Updates the participant/mentor filter cache
  def update_filter_cache
    person.save
  end
  
  def event_name
    event.try(:name)
  end

  # Class method to use along with other named scopes to limit results to a specific audience group.
  def self.audience(audience_name = Person)
    audience_name ||= Person
    joins(:person).where(["(audience = :audience) OR (people.type = :audience AND audience IS NULL)", {:audience => audience_name.to_s.classify}])
  end
  
  def enforce_rsvp_limits?
    enforce_rsvp_limits
  end
  
  # Sends the rsvp email or cancel email if the RSVP has changed.
  def send_email
    if event.send_attendance_emails? && rsvp_changed?
      if rsvp?
        RsvpMailer.rsvp(self).deliver
      else
        RsvpMailer.cancel(self).deliver
      end
    end
  end
  
  def validate_event_shift
    if event.has_shifts?(person.class) && rsvp_changed? && rsvp? && event_shift_id.nil?
      errors.add :event_shift_id, :message => "must choose a shift from the list"
    end
  end

  def validate_rsvp_limits
    if event.full?(person) && rsvp_changed? && rsvp?
      errors.add :rsvp, :message => "can't be saved because the capacity limit for this event has been reached"
      errors.add :enforce_rsvp_limits
    end
  end

  def validate_rsvps_not_disabled
    if event.rsvps_disabled?(audience) && rsvp_changed? && rsvp == false
      errors[:base] << "It is too close to the event to cancel your RSVP. #{event.event_group.disable_message(audience)}"
    end
  end

  def completed_training?
    person.completed_training?(event.training_for(person))
  end

  def name_with_shift_title
    event_shift.nil? ? event.name : "#{event.name} (#{event_shift.title})"
  end
  
  # Returns a string representation of the person type 
  # this event attendance will be displayed under
  # Override
  def audience
    read_attribute(:audience) || person.class.to_s
  end
  
  # Before we save the record, check if `attended = true` but `attendance_option` is blank. If so,
  # set `attendance_option` to "Attended".
  def replace_blank_attendance_option
    self.attendance_option = "Attended" if attended? && attendance_option.blank?
  end
  
	def self.xlsx_columns
		columns = []
    columns << [:person_id, :lastname, :firstname, :event_id, :event_name, :date, :start_time, :end_time]
		columns << self.column_names.map { |c| c = c.to_sym }
    columns.flatten
	end
  
end
