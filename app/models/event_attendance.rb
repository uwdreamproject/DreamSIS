class EventAttendance < ActiveRecord::Base
  belongs_to :event
  belongs_to :person
  belongs_to :event_shift
  
  validates_presence_of :person_id, :event_id
  validates_uniqueness_of :person_id, :scope => :event_id, :message => "already has an event attendance record for this event"

  validate :validate_event_shift
  
  validate :validate_rsvp_limits, :if => :enforce_rsvp_limits?
  
  delegate :fullname, :email, :to => :person
  delegate :has_shifts?, :to => :event
  
  after_save :send_email
  
  alias :shift :event_shift
  attr_accessor :enforce_rsvp_limits
  
  attr_protected :admin
  
  def enforce_rsvp_limits?
    enforce_rsvp_limits
  end
  
  # Sends the rsvp email or cancel email if the RSVP has changed.
  def send_email
    if rsvp_changed?
      if rsvp?
        RsvpMailer.deliver_rsvp!(self)
      else
        RsvpMailer.deliver_cancel!(self)
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

  def completed_training?
    person.completed_training?(event.training_for(person))
  end

  def name_with_shift_title
    event_shift.nil? ? event.name : "#{event.name} (#{event_shift.title})"
  end
  
end
