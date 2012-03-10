class EventGroup < ActiveRecord::Base
  has_many :events do
    def future
      find :all, :conditions => ["date >= ?", Time.now.midnight]
    end
  end
  
  belongs_to :event_type
  
  validates_presence_of :name
  
end
