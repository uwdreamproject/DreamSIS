=begin
  High schools have weekly high school meetings, which are attended by both Participants and Staff.
=end
class Visit < Event

  # Never send attendance emails for Visits.
  def send_attendance_emails?
    false
  end
  
end