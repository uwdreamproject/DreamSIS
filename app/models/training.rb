class Training < CustomerScoped
  validates_presence_of :title, :video_url
  
  has_many :completions, :class_name => "TrainingCompletion"
  
  default_scope :conditions => { :customer_id => lambda {Customer.current_customer.id}.call }
end
