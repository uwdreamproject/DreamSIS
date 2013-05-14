# Subclass of Degree specifically for college degrees.
class CollegeDegree < Degree
  validates_presence_of :institution_id
  
  belongs_to :clearinghouse_request

  def institution
    @institution ||= Institution.find(institution_id)
  end
  
  
end