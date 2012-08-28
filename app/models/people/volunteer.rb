# A Volunteer is a member of the community who volunteers to participate at an event or in another way for a specific period of time.
class Volunteer < ExternalPerson
  
  validates_presence_of :background_check_authorized_at, :shirt_size, :organization, :if => :validate_ready_to_rsvp?
  
end