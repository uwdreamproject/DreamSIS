class CustomerScoped < ActiveRecord::Base
  self.abstract_class = true
  @columns = []

  belongs_to :customer
  attr_protected :customer_id
  validates_presence_of :customer_id
  
  before_save :append_customer_id

  default_scope :conditions => { :customer_id => lambda {Customer.current_customer.id}.call }

  # Add a manual scope to all find methods that adds the current customer ID to the query.
  def self.find(*args)
    with_scope(
      :find => { :conditions => { :customer_id => lambda {Customer.current_customer.id}.call } }, 
      :create => { :customer_id => lambda {Customer.current_customer.id}.call }
    ) do
      super(*args)
    end
  end

  def self.count(*args)
    with_scope(:find => { :conditions => { :customer_id => lambda {Customer.current_customer.id}.call } }) do
      super(*args)
    end
  end
  
  # Adds the current customer ID to the record, which is used +before_create+.
  def append_customer_id
    self.customer_id = Customer.current_customer.id
  end
  
end
