class EventGroup < ActiveRecord::Base
  has_many :events do
    def future
      find :all, :conditions => ["date >= ?", Time.now.midnight]
    end
  end
  
  belongs_to :event_type  
  validates_presence_of :name
  
  belongs_to :volunteer_training, :class_name => "Training"
  belongs_to :mentor_training, :class_name => "Training"
  
  # Returns true if either +allow_external_students+ or +allow_external_volunteers+ is true.
  def open_to_public?
    allow_external_students? || allow_external_volunteers?
  end
  
end
