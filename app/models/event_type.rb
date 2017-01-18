class EventType < ApplicationRecord
  has_many :events do
    def future
      find :all, conditions: ["date >= ?", Time.now.midnight]
    end
  end
  
  has_many :event_groups
  
  validates_presence_of :name
  
  # EventTypes are never open to the public (at least, not in current implementation). Only EventGroups are.
  def open_to_public?
    false
  end
  
end
