=begin
  High schools have weekly high school meetings, which are attended by both Participants and Staff.
=end
class Visit < Event

  # Never send attendance emails for Visits.
  def send_attendance_emails?
    false
  end
  
  def visit?
    true
  end
  
  def attendance_options
    Customer.uses_visit_attendance_options? ? Customer.visit_attendance_options_array : []
  end
  
  def name
    read_attribute(:name) || Customer.visit_Label
  end
  
end