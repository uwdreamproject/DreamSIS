# Models a participant's enrollment at a particular institution or high school.
class Enrollment < ApplicationRecord
  validates_presence_of :participant_id
  belongs_to :participant, touch: true
  
  validates_uniqueness_of :institution_id, scope: [:participant_id, :began_on, :ended_on, :enrollment_status, :class_level], message: "an identical enrollment already exists with those attributes for the participant"
  
  after_save :update_filter_cache
  after_destroy :update_filter_cache

  default_scope { order("ended_on DESC, began_on DESC") }

  # Updates the participant filter cache
  def update_filter_cache
    participant.save
  end
  
end
