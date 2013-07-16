# Subclass of Enrollment specifically for college enrollments.
class CollegeEnrollment < Enrollment
  validates_presence_of :institution_id
  
  belongs_to :clearinghouse_request
  belongs_to :grade_level, :foreign_key => :abbreviation, :primary_key => :class_level

  CLASS_LEVEL_NAMES = {
    "C" => "Certificate (Undergraduate)",
    "A" => "Associate's",
    "B" => "Bachelor's",
    "F" => "Freshman",
    "S" => "Sophomore",
    "J" => "Junior",
    "R" => "Senior",
    "N" => "Unspecified (Undergraduate)",
    "T" => "Post-baccalaureate Certificate",
    "M" => "Master's",
    "D" => "Doctoral",
    "P" => "Postdoctorate",
    "L" => "Professional",
    "G" => "Unspecified (Graduate/Professional)"
  }
  
  ENROLLMENT_STATUS_NAMES = {
    "F" => "Full-time",
    "H" => "Half-time",
    "L" => "Less than half-time",
    "W" => "Withdrawn",
    "G" => "Graduated",
    "A" => "Leave of Absence",
    "D" => "Deceased"
  }

  def institution
    @institution ||= Institution.find(institution_id)
  end
  
  # Returns a printable String of the names of the majors for this record.
  def majors_list
    [major_1, major_2].select{|m| !m.blank? }.collect(&:titleize).join(", ")
  end
  
  # Returns the name of the +class_level+ based on the CLASS_LEVEL_NAMES mapping.
  def class_level_name
    CLASS_LEVEL_NAMES[class_level.to_s.strip]
  end

  # Returns the name of the +enrollment_status+ based on the ENROLLMENT_STATUS_NAMES mapping.
  def enrollment_status_name
    ENROLLMENT_STATUS_NAMES[enrollment_status.to_s.strip]
  end

  
end