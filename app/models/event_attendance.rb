class EventAttendance < ActiveRecord::Base
  belongs_to :event
  belongs_to :person
  
  validates_presence_of :person_id, :event_id
  validates_uniqueness_of :person_id, :scope => :event_id, :message => "already has an event attendance record for this event"
  
  delegate :fullname, :email, :to => :person
  
  after_save :send_email
  
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
  
end
