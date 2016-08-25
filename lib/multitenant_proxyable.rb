module MultitenantProxyable
  extend ActiveSupport::Concern

  included do
    has_many :proxies, as: :proxyable, class_name: "MultitenantProxy", dependent: :destroy
    after_save :update_proxies
    after_create :create_proxies
  end

  module ClassMethods
    def acts_as_proxyable(options = {})
      cattr_accessor :proxy_parent
      cattr_accessor :proxy_dependents
      cattr_accessor :proxy_parent_direction
      self.proxy_dependents = options[:dependents] || []
      self.proxy_parent = options[:parent]
      self.proxy_parent_direction = options[:parent_direction]
    end
  end

  # Defines the attributes to copy over to a proxied slave object. Override this method as needed.
  def proxyable_attributes
    excluded = %w[id created_at updated_at]
    attributes.except(*excluded)
  end
  
  # Prepares the attribute overrides for this object based on the parent and child objects.
  def attribute_overrides
    parent_attributes
  end
  
  def parent_attributes
    # FIXME probably should not rely on the first proxy being the right one.
    return {} if parent_object_proxies.first.nil?
    self.proxy_parent.nil? ? {} : { self.proxy_parent.to_s.foreign_key => parent_object_proxies.first.other_id }
  end
  
  # Convenience method to check if there are any proxies setup for this object.
  def proxies?
    !proxies.empty?
  end
  
  # Triggered from a callback; requests the object's slave(s) to be updated
  def update_proxies
    return create_proxies if !parent_object_proxies.empty? && proxies.master.empty?
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
    return nil if parent_object_proxies.empty?
    
    new_proxies = []
    for parent_object_proxy in parent_object_proxies
      other_customer_id = parent_object_proxy.other_customer_id
      new_master = proxies.master.create(other_customer_id: other_customer_id)
      new_master.create_slave_object  
      new_proxies << new_master
    end
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

  # Returns the MultitenantProxy object(s) attached to this object's +parent_object+.
  #
  # * "Forward" direction means that we create/update an equivalent object when the
  #   parent object is a Master. For example, EventShift is set to the "forward" direction
  #   because when we add an EventShift to a master Event, we want that EventShift to
  #   propogate to all the slave Event objects. In this case, this method may return
  #   multiple MultitenantProxy objects.
  #
  # * "Reverse" direction means that we create/update an equivalent object when the
  #   parent object is a Slave. For example, EventAttendance is set to the "reverse"
  #   direction because when someone RSVP's for an event by creating an attendance
  #   record, we only want to propogate that back to the master object. If a new
  #   EventAttendance object is created on the master object, we don't want that to
  #   propogate down to the slave objects.
  def parent_object_proxies
    # parent_object.proxies.slave.first if parent_object
    
    return [] unless parent_object
    
    if self.proxy_parent_direction == :forward
      parent_object.proxies.master
    elsif self.proxy_parent_direction == :reverse
      parent_object.proxies.slave
    end
  end

end


# # EventAttendance
# #   dependents: event_shift, person
# #   parent: event
#   after create:
#     if event is slave, create equivalent in master
#     if event is master, do not create equivalent in slave
#       only create/update if event is slave
#
# # EventShift
# #   dependents: ---
# #   parent: event
#     if event is slave, do not create equivalent in master
#     if event is master, create equivalent in slave
#       only create/update if event is master
#       propogate to all others
#
# # Event
# #   dependents: location
# #   parent: event_group
# only create/update if event_group is master
# propogate to all others
#
# # Person
# #   dependents: ---
# #   parent: ---
#
# # Location
# #   dependents: ---
# #   parent: ---
