# A Student is a generic model for an external student. Students can be linked with Participants if that student becomes a participant later (or already existed as a participant but logged in as a generic student first). This is typically used for events that are open to the public, to allow students to log in regardless of their participation in the Dream Project.
class Student < ExternalPerson
    
  belongs_to :high_school
  validates_presence_of :birthdate, :high_school_id, if: :validate_ready_to_rsvp?
  
  scope :in_cohort, ->(grad_year) { where(grad_year: grad_year) }
  scope :in_high_school, ->(high_school_id) { where(high_school_id: high_school_id) }
  
end
