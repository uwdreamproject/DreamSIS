class CollegeApplication < ActiveRecord::Base
  
  # belongs_to :institution
  belongs_to :participant
  
  validates_presence_of :institution_id, :participant_id
  validates_uniqueness_of :institution_id, :scope => :participant_id, :message => "is already assigned to another college application for this participant"
  validates_numericality_of :institution_id
  validates_exclusion_of :institution_id, :in => [0], :message => "ID can't be set to zero" # make sure this doesn't get set to zero, but allow any other positive or negative integer
  
  delegate :name, :to => :institution
  
  attr_accessor :institution_name

  # Returns true if this application represents the college that the student is actually attending.
  def attending?
    institution_id == participant.college_attending_id
  end
  
  def institution
    @institution ||= Institution.find(institution_id)
  end
  
  # Returns an array of the most commonly selected institution codes. Specify a number to limit.
  # Default is 10.
  def self.top_institutions(limit = 10)
    @top_institutions ||= CollegeApplication.find(:all, 
      :group => :institution_id, 
      :select => "institution_id, COUNT(institution_id) AS count", 
      :limit => limit,
      :order => "count DESC").collect(&:institution).compact
  end
  
end
