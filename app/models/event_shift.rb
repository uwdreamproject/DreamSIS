class EventShift < CustomerScoped
  belongs_to :event
  validates_presence_of :title
  
  default_scope :conditions => { :customer_id => lambda {Customer.current_customer.id}.call }
  
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
