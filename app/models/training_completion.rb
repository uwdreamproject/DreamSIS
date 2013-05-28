class TrainingCompletion < CustomerScoped
  validates_presence_of :training_id, :person_id
  validates_uniqueness_of :person_id, :scope => :training_id
  
  belongs_to :training
  belongs_to :person
  
  default_scope :conditions => { :customer_id => lambda {Customer.current_customer.id}.call }
  
  def completed?
    !completed_at.nil?
  end
end
