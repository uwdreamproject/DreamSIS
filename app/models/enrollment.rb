# Models a participant's enrollment at a particular institution or high school.
class Enrollment < CustomerScoped
  validates_presence_of :participant_id  
  belongs_to :participant
  
  validates_uniqueness_of :institution_id, :scope => [:participant_id, :began_on, :ended_on, :enrollment_status, :class_level]
end
