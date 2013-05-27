# Models a specific type of test that a Participant can take, like SAT or ACT. Defines the maximum scores and sections of the test as well.
# 
# Note: The class name "TestType" is used to avoid namespace conflicts with Ruby or Rails' use of "Test".
class TestType < CustomerScoped
  has_many :test_scores
  
  validates_presence_of :name
  validates_numericality_of :maximum_total_score
  
  default_scope :order => "name"
  
  # Returns a hash with the section name as key and the maximum score as value.
  # If no sections are defined, this returns an empty hash.
  def section_scores_hash
    return @section_scores_hash if @section_scores_hash
    @section_scores_hash = {}
    for section in sections.strip.split("\r\n")
      section = section.split(":")
      value = section[1].nil? ? nil : section[1].to_s.strip.try(:to_i)
      @section_scores_hash[section[0].to_s.strip] = value
    end
    @section_scores_hash
  end
  
end
