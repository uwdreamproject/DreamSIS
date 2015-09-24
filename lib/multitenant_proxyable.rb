module MultitenantProxyable
  extend ActiveSupport::Concern

  included do
    has_many :proxies, :as => :proxyable, :class_name => "MultitenantProxy", :dependent => :destroy
    after_save :update_proxies
    after_create :create_proxies
  end

  module ClassMethods
    def acts_as_proxyable(options = {})
      cattr_accessor :proxy_parent
      cattr_accessor :proxy_dependents
      cattr_accessor :proxy_passthroughs
      self.proxy_dependents = options[:dependents] || []
      self.proxy_parent = options[:parent]
      # self.proxy_passthroughs = options[:passthrough] || []
      
      # for passthrough in proxy_passthroughs
      #   alias_method "#{passthrough.to_s}_without_passthrough", "#{passthrough.to_s}"
      #
      #   define_method(passthrough) do
      #     logger.info { "Passing through method ##{passthrough.to_s}" }
      #     logger.info { "Current proxies.slave: #{proxies.slave.inspect}" }
      #     if proxies.slave.empty?
      #       instance_eval("#{passthrough.to_s}_without_passthrough")
      #     else
      #       proxies.slave.first.other_object
      #     end
      #   end
      # end
      
    end
  end

  # Defines the attributes to copy over to a proxied slave object. Override this method as needed.
  def proxyable_attributes
    excluded = %w[id created_at updated_at]
    attributes.except(*excluded)
  end
  
  # Prepares the attribute overrides for this object based on the parent and child objects.
  def attribute_overrides
    parent_attributes #.merge(passthrough_attributes)
  end
  
  def parent_attributes
    { self.proxy_parent.to_s.foreign_key => parent_object_proxy.other_id }
  end
  
  # def passthrough_attributes
  #   h = {}
  #   for proxy_passthrough in self.proxy_passthroughs
  #     h[proxy_passthrough.to_s.foreign_key] = 14 #:proxy_passthrough
  #   end
  #   h
  # end
    
  # Convenience method to check if there are any proxies setup for this object.
  def proxies?
    !proxies.empty?
  end
  
  # Triggered from a callback; requests the object's slave(s) to be updated
  def update_proxies
    proxies.master.each{ |p| p.update_slave }
  end
  
  # Returns this object's slave object in the given customer, if it exists, or creates it.
  def find_or_create_slave_object(customer_id)
    existing = proxies.master.for_customer(customer_id)
    existing.empty? ? existing.first.other_object : existing.create.create_slave_object
  end

  # Creates the necessary proxy objects when creating this record. Automatically returns
  # nil if there is no proxy parent object set.
  #
  # 1. Find the parent objects' correct ID's to use in the new record (e.g., +event_id+)
  #    and the appropriate customer ID to use when creating this object.
  # 2. Find or create dependent objects to populate the correct ID's in the new
  #    record (e.g., +person_id+, +event_shift_id+).
  # 3. Create the proxy object.
  def create_proxies
    return nil unless parent_object_proxy
    
    # Create the proxy object
    other_customer_id = parent_object_proxy.other_customer_id
    new_master = proxies.master.create(other_customer_id: other_customer_id)
    
    # Create the proxy slave object
    new_master.create_slave_object
    
    return new_master
  end

  private

  # Dependent objects need to be linked/proxied before we can save the current object.
  # For example, if current object is EventAttendance, we can't save the proxy object
  # in the other customer without a Person ID. Therefore we must find or create the
  # Person proxy object first, and then use that ID when creating this object's proxy
  # slave.
  def dependent_objects
    self.proxy_dependents.collect{ |dependent_type| instance_eval(dependent_type) }
  end
  
  # Returns the parent object in the current tenant. Specify the parent object when
  # defining this class's proxy relationship with `acts_as_proxyable parent: :event`.
  def parent_object
    instance_eval(self.proxy_parent.to_s)
  end

  # Returns the first (which should be only) MultitenantProxy object attached to this
  # object's +parent_object+.
  def parent_object_proxy
    parent_object.proxies.slave.first if parent_object
  end

end


# EventAttendance
#   dependents: event_shift
#   parent: event
#   passthrough: person

# Person
#   dependents: ?
#   parent: ---

# EventShift
#   dependents: ---
#   parent: event

# Event
#   passthrough: location (no need to proxy)
#   dependents: ---
#   parent: event_group