# Used to link an object to a master/slave object that belonds to another tenant. The primary use case is events that are open to people from other programs. An Event may be set up as a master object in the tenant that is running the event, and other programs' participants may RSVP for that Event. To maintain tenant separation, the proxy object keeps the two objects in sync, including slave objects like EventAttendance.
class MultitenantProxy < ActiveRecord::Base
  belongs_to :proxyable, :polymorphic => true, :touch => true
  belongs_to :other_customer, :class_name => "Customer"
  
  validates_presence_of :proxyable_type, :proxyable_id, :role, :other_customer_id
  validates_uniqueness_of :proxyable_id, :scope => [:proxyable_type, :role, :other_customer_id, :other_id]
  
  attr_accessible :other_id, :proxyable_id, :proxyable_type, :role, :other_customer_id

  ExcludedAttributes = %w[id created_at updated_at]
  
  scope :master, where(role: "master")
  scope :slave, where(role: "slave")
  scope :for_customer, lambda{ |customer_id| where(other_customer_id: customer_id) }
  
  # Returns the object from the other side of the proxy, using Apartment::Tenant.process.
  def other_object
    return nil unless other_id
    _other { proxyable.class.find(other_id) } rescue nil
  end
  
  # Returns true if this object is the Master object.
  def master?
    role.to_s == "master"
  end
    
  # Returns true if this object is the Slave object.
  def slave?
    role.to_s == "slave"
  end
    
  # Creates a new Slave object in the other tenant based on this Master object.
  def create_slave_object
    raise Exception.new("Cannot create slave object unless current object is Master") unless master?
    raise Exception.new("Slave object already exists") if other_object
    raise Exception.new("Cannot create slave object until current object is valid") unless valid? && persisted?

    Rollbar.warning "Sidekiq not ready" unless Report.sidekiq_ready?
    MultitenantProxyWorker.perform_async(Customer.tenant_name, self.id)
  end
  
  # Returns the attributes that should be copied to, or kept in sync with, a Slave object.
  # By default, this method looks to see if the proxyable defines a method called +proxyable_attributes+
  # and uses that if it can. Otherwise it uses all attributes and strips out the ExcludedAttributes list.
  def proxyable_attributes
    return proxyable.proxyable_attributes if proxyable.respond_to?(:proxyable_attributes)
    attribute_names = proxyable.attribute_names - ExcludedAttributes
    proxyable.attributes.select{ |key, value| attribute_names.include?(key) }
  end
  
  # Replicates the relevant changes over to other objects. Usually called from an +after_save+ callback on
  # an object. If this is a Master object, then we update the attributes on the Slave object.
  def update_slave
    return false unless master?
    Rollbar.warning "Sidekiq not ready" unless Report.sidekiq_ready?
    MultitenantProxyWorker.perform_async(Customer.tenant_name, self.id)
  end
  
  protected
  
  # Perform this operation on the other tenant.
  def _other(*args, &block)
    Apartment::Tenant.process(other_customer.tenant_name) do
      block.call(*args)
    end
  end

end
