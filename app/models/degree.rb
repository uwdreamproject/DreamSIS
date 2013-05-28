# Models a degree that a Participant has earned, like a high school diploma or a college degree.
class Degree < CustomerScoped
  validates_presence_of :participant_id
  belongs_to :participant
  
  validates_uniqueness_of :institution_id, :scope => [:participant_id, :graduated_on, :degree_title]
  
  default_scope :conditions => { :customer_id => lambda {Customer.current_customer.id}.call }
end
