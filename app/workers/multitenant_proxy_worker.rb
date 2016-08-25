class MultitenantProxyWorker
  include Sidekiq::Worker

  # Creates or updates the slave object connected to this master object.
  def perform(tenant_name, multitenant_proxy_id)
    return true
    # begin
      ActiveRecord::Base.connection_pool.with_connection do
        Apartment::Tenant.switch(tenant_name)
        log multitenant_proxy_id, "Performing async slave update in `#{tenant_name}`"
        
        # Fetch the details of the proxy Master object.
        @proxy_object = MultitenantProxy.find(multitenant_proxy_id)
        @new_attributes = @proxy_object.proxyable_attributes.merge(@proxy_object.proxyable.attribute_overrides)
        @other_tenant = @proxy_object.other_customer.tenant_name
        log multitenant_proxy_id, "Proxy object: #{@proxy_object.inspect}"
        
        if @proxy_object.other_id.nil?
          create_slave(@proxy_object, @new_attributes, @other_tenant)
        else
          update_slave(@proxy_object, @new_attributes, @other_tenant)
        end
      end
      
    # rescue => e
    #   log multitenant_proxy_id, "ERROR: #{e.message}"
    #   Rollbar.error(e, multitenant_proxy_id: multitenant_proxy_id)
    # end
  end

  # Creates the slave object and updates the proxy's +other_id+.
  def create_slave(proxy_object, new_attributes, other_tenant)
    log proxy_object.id, "We need to create a new slave <#{proxy_object.proxyable_type}> in `#{other_tenant}`"
    current_customer_id = Customer.id
    
    # Figure out the correct ID's to use for the dependent objects.
    log proxy_object.id, "First we need to create or find the slave proxies for these dependents: #{proxy_object.proxyable.proxy_dependents}"
    for dependent_key in proxy_object.proxyable.proxy_dependents
      dependent_object = proxy_object.proxyable.try(dependent_key)
      log proxy_object.id, "#{dependent_key} => #{dependent_object.inspect}"
      next if dependent_object.nil?
      dependent_proxies = dependent_object.proxies.master.for_customer(proxy_object.other_customer_id)
      if dependent_proxies.empty? || dependent_proxies.first.other_id.nil?
        log proxy_object.id, "No dependent proxy found or no other_id set; creating new other object."
        dependent_master = dependent_object.proxies.master.for_customer(proxy_object.other_customer_id).first_or_create
        new_other_object = create_object(dependent_master, dependent_object.proxyable_attributes, other_tenant)
        log proxy_object.id, "Created this other object: #{new_other_object.inspect}"
        other_object_id = new_other_object.id
      else
        log proxy_object.id, "Found #{dependent_proxies.first.try(:inspect)}"
        other_object_id = dependent_proxies.first.other_id
      end

      new_attributes[dependent_key.to_s.foreign_key] = other_object_id
    end

    # Create the other object and update the proxy.
    new_other_object = create_object(proxy_object, new_attributes, other_tenant)
    proxy_object.update_attribute(:other_id, new_other_object.try(:id))
  end

  # Updates the slave object with new attributes.
  def update_slave(proxy_object, new_attributes, other_tenant)
    log proxy_object.id, "We need to update the slave <#{proxy_object.proxyable_type} id:#{proxy_object.other_id}> in `#{other_tenant}`"
    
    # Need to attach the ID's for the dependent objects.
    for dependent_key in proxy_object.proxyable.proxy_dependents
      log proxy_object.id, "Adding dependent key #{dependent_key}"
      dependent_object = proxy_object.proxyable.try(dependent_key)
      log proxy_object.id, "#{dependent_key} => #{dependent_object.inspect}"
      if dependent_object
        dependent_proxies = dependent_object.proxies.for_customer(proxy_object.other_customer_id)
        log proxy_object.id, "dependent_proxies: #{dependent_proxies.inspect}"
        new_attributes[dependent_key.to_s.foreign_key] = dependent_proxies.first.other_id if dependent_proxies.first
        log proxy_object.id, "#{dependent_key.to_s.foreign_key} => #{dependent_proxies.first.other_id}" if dependent_proxies.first
      end
    end

    Apartment::Tenant.process(other_tenant) do
      # Update the attributes of the slave object using the attributes from the master object.
      slave_object = proxy_object.proxyable_type.constantize.find(proxy_object.other_id)
      log proxy_object.id, "New attributes: #{new_attributes.inspect}"
      slave_object.update_attributes(new_attributes)
    end
  end

  def log(id, message)
    Rails.logger.info { "[MultitenantProxy #{id}] #{message}" } # \n\tin #{caller_locations(4, 6).join("\n\t")}"}
  end
  
  # Creates the new object based on the attributes provided.
  def create_object(proxy_object, new_attributes, other_tenant)
    log proxy_object.id, "Creating new object in `#{other_tenant}`"
    log proxy_object.id, "Current proxy_object: #{proxy_object.inspect}"
    log proxy_object.id, "New attributes for object: #{new_attributes.inspect}"
    current_customer_id = Customer.id
    object_class = proxy_object.proxyable.class

    new_other_object = Apartment::Tenant.process(other_tenant) do

      # Create the object
      obj = object_class.create(new_attributes)
      
      # Create the slave proxy
      obj.proxies.slave.create(
        other_customer_id: current_customer_id,
        other_id: proxy_object.proxyable_id
      )

      log proxy_object.id, obj.inspect
      return obj
    end
    
    log proxy_object.id, new_other_object.errors.inspect unless new_other_object.valid?
    return obj
  end
  
end
