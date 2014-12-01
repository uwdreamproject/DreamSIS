# Send emails for event RSVP's.
class RsvpMailer < ActionMailer::Base  

  default :from => "events@dreamsis.com", "X-MC-Subaccount" => Apartment::Tenant.current

  def rsvp(event_attendance, sent_at = Time.now)
    
    @event_attendance = event_attendance
    @event = @event_attendance.event
    @time_detail = @event.time_detail(:audience => event_attendance.audience)
    @event_description = @event.description(event_attendance.audience)
    @confirmation_message = @event.event_group.confirmation_message(event_attendance.audience) if @event.event_group
    mail(:subject =>"Thanks for registering: #{@event.name}",
    :to => "#{@event_attendance.person.try(:fullname)} <#{@event_attendance.person.try(:email)}>",
    :from =>      "do-not-reply@dreamsis.com",
    :sent_on  =>  sent_at,
    :css => :email)
  end

  def cancel(event_attendance, sent_at = Time.now)
    
    @event_attendance = event_attendance
    @event = @event_attendance.event
    mail(
    :subject =>    "Registration canceled: #{@event.name}",
    :to => "#{@event_attendance.person.try(:fullname)} <#{@event_attendance.person.try(:email)}>",
    :from =>      "do-not-reply@dreamsis.com",
    :sent_on =>    sent_at,
    :css => :email)
  end

  def reminder(event_attendance, sent_at = Time.now)
    @event_attendance = event_attendance
    @event = @event_attendance.event
    mail(
    :subject =>   "Event Reminder: #{@event.name}",
    :to => "#{@event_attendance.person.try(:fullname)} <#{@event_attendance.person.try(:email)}>",
    :from  =>     "do-not-reply@dreamsis.com",
    :sent_on =>   sent_at)
  end

end
