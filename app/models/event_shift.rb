class EventShift < ActiveRecord::Base
  belongs_to :event
  validates_presence_of :title
  
  def details_string
    str = title
    if start_time
      str << " ("
      str << start_time.to_s(:time12)
      str << "-" + end_time.to_s(:time12) if end_time
      str << ")"
    end
    str
  end
  
end
