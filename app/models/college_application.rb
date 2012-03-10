class CollegeApplication < ActiveRecord::Base
  
  belongs_to :institution
  belongs_to :participant
  
  validates_presence_of :institution_id, :participant_id
  validates_uniqueness_of :institution_id, :scope => :participant_id
  
  delegate :name, :to => :institution
  
  # Returns true if this application represents the college that the student is actually attending.
  def attending?
    institution_id == participant.college_attending_id
  end
  
  # Returns an array of the most commonly selected institution codes. Specify a number to limit.
  # Default is 10.
  def self.top_institutions(limit = 10)
	@top_institutions ||= CollegeApplication.find(:all, 
		:group => :institution_id, 
		:select => "institution_id, COUNT(institution_id) AS count", 
		:limit => limit, 
		:include => :institution, 
		:order => "count DESC").collect(&:institution)
  end
  
end
