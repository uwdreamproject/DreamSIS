# Models a degree that a Participant has earned, like a high school diploma or a college degree.
class Degree < ActiveRecord::Base
  validates_presence_of :participant_id
  belongs_to :participant, touch: true
  
  validates_uniqueness_of :institution_id, scope: [:participant_id, :graduated_on, :degree_title]
  
  after_save :update_filter_cache
  after_destroy :update_filter_cache

  # Updates the participant filter cache
  def update_filter_cache
    participant.save
  end
  
end
