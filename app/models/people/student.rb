# A Student is a generic model for an external student. Students can be linked with Participants if that student becomes a participant later (or already existed as a participant but logged in as a generic student first). This is typically used for events that are open to the public, to allow students to log in regardless of their participation in the Dream Project.
class Student < ExternalPerson
  
  validates_presence_of :high_school_id, :if => :validate_ready_to_rsvp?
  
  
end