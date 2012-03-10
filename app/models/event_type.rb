class EventType < ActiveRecord::Base
  has_many :events do
    def future
      find :all, :conditions => ["date >= ?", Time.now.midnight]
    end
  end
  
  has_many :event_groups
  
  validates_presence_of :name
end
