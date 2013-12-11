class CollegeApplication < ActiveRecord::Base
  
  # belongs_to :institution
  belongs_to :participant
  
  validates_presence_of :institution_id, :participant_id
  validates_uniqueness_of :institution_id, :scope => :participant_id, :message => "is already assigned to another college application for this participant"
  validates_numericality_of :institution_id
  validates_exclusion_of :institution_id, :in => [0], :message => "ID can't be set to zero" # make sure this doesn't get set to zero, but allow any other positive or negative integer
  
  delegate :name, :to => :institution
  
  before_destroy :destroy_college_mapper_college, :if => :do_college_mapper_functions?
  after_create :create_college_mapper_college, :if => :do_college_mapper_functions?  
  
  attr_accessor :institution_name

  after_save :update_filter_cache
  after_destroy :update_filter_cache

  # Updates the participant filter cache
  def update_filter_cache
    participant.save
  end

  # Returns true if this application represents the college that the student is actually attending.
  def attending?
    institution_id == participant.try(:college_attending_id)
  end
  
  def institution
    @institution ||= Institution.find(institution_id)
  end
  
  def applied?
    !date_applied.nil?
  end
  
  def do_college_mapper_functions?
    !participant.college_mapper_id.nil? rescue false
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

  # Fetches the CollegeMapperCollege resource associated with this object.
  def college_mapper_college
    return nil unless participant.college_mapper_id
    @college_mapper_college ||= CollegeMapperCollege.find(institution_id, :params => { :user_id => participant.college_mapper_id })
  end

  # Creates a new CollegeMapperCollege resource for this record. If the instition_id is less than 0
  # (meaning this is a DreamSIS-only institution record) or nil, then return false.
  def create_college_mapper_college
    return false unless participant.college_mapper_id
    return false if institution_id.nil? || institution_id <= 0
    @college_mapper_college = CollegeMapperCollege.create({
      :user_id => participant.college_mapper_id,
      :collegeId => institution_id
    })
    @college_mapper_college
  rescue ActiveResource::BadRequest => e
    logger.info { e.message }
    false
  end

  # Destroys the CollegeMapperCollege resource for this record if it exists.
  def destroy_college_mapper_college
    return false unless participant.college_mapper_id
    college_mapper_college.destroy if college_mapper_college
  end
  
end
