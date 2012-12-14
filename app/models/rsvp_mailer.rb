# Send emails for event RSVP's.
class RsvpMailer < ActionMailer::Base  

  ActionMailer::Base.default_url_options[:host] = "dreamsis.org"

  def rsvp(event_attendance, sent_at = Time.now)
    css :email
    
    @event_attendance = event_attendance
    @event = @event_attendance.event
    @event_description = @event.description(event_attendance.person.class)
    @confirmation_message = @event.event_group.confirmation_message(event_attendance.person.class) if @event.event_group
    subject    "Thanks for registering: #{@event.name}"
    recipients "#{@event_attendance.person.try(:fullname)} <#{@event_attendance.person.email}>"
    from       "do-not-reply@dreamsis.org"
    sent_on    sent_at
  end

  def cancel(event_attendance, sent_at = Time.now)
    css :email
    
    @event_attendance = event_attendance
    @event = @event_attendance.event
    subject    "Registration canceled: #{@event.name}"
    recipients "#{@event_attendance.person.try(:fullname)} <#{@event_attendance.person.email}>"
    from       "do-not-reply@dreamsis.org"
    sent_on    sent_at
  end

  def reminder(event_attendance, sent_at = Time.now)
    css :email
    
    @event_attendance = event_attendance
    @event = @event_attendance.event
    subject    "Event Reminder: #{@event.name}"
    recipients "#{@event_attendance.person.try(:fullname)} <#{@event_attendance.person.email}>"
    from       "do-not-reply@dreamsis.org"
    sent_on    sent_at
  end

end
