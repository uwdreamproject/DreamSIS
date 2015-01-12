# Subclass of Degree specifically for college degrees.
class CollegeDegree < Degree
  validates_presence_of :institution_id
  
  belongs_to :clearinghouse_request
  belongs_to :institution

  # Returns a printable String of the names of the majors for this record.
  def majors_list
    [major_1, major_2, major_3, major_4].select{|m| !m.blank? }.collect(&:titleize).join(", ")
  end  
  
end