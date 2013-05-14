# Models a degree that a Participant has earned, like a high school diploma or a college degree.
class Degree < ActiveRecord::Base
  validates_presence_of :participant_id
  belongs_to :participant
  
  validates_uniqueness_of :institution_id, :scope => [:participant_id, :graduated_on, :degree_title]
end
