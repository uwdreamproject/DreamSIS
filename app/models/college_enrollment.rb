# Subclass of Enrollment specifically for college enrollments.
class CollegeEnrollment < Enrollment
  validates_presence_of :institution_id
  
  belongs_to :clearinghouse_request

  def institution
    @institution ||= Institution.find(institution_id)
  end
    
end