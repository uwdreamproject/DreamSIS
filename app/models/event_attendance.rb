class EventAttendance < ActiveRecord::Base
  belongs_to :event
  belongs_to :person
  
  validates_presence_of :person_id, :event_id
  validates_uniqueness_of :person_id, :scope => :event_id, :message => "already has an event attendance record for this event"
  
  delegate :fullname, :email, :to => :person
  
end
