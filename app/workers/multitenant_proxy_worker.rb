class MultitenantProxyWorker
  include Sidekiq::Worker

  # Creates or updates the slave object connected to this master object.
  def perform(tenant_name, multitenant_proxy_id)
    begin
      ActiveRecord::Base.connection_pool.with_connection do
        Apartment::Tenant.switch(tenant_name)
        log multitenant_proxy_id, "Performing async slave update in `#{tenant_name}`"
        
        # Fetch the details of the proxy Master object.
        @proxy_object = MultitenantProxy.find(multitenant_proxy_id)
        @new_attributes = @proxy_object.proxyable_attributes.merge(@proxy_object.proxyable.attribute_overrides)
        @other_tenant = @proxy_object.other_customer.tenant_name
        
        if @proxy_object.other_id.nil?
          create_slave(@proxy_object, @new_attributes, @other_tenant)
        else
          update_slave(@proxy_object, @new_attributes, @other_tenant)
        end
      end
      
    rescue => e
      log multitenant_proxy_id, "ERROR: #{e.message}"
      Rollbar.error(e, :multitenant_proxy_id => multitenant_proxy_id)
    end
  end

  # Creates the slave object and updates the proxy's +other_id+.
  def create_slave(proxy_object, new_attributes, other_tenant)
    log proxy_object.id, "We need to create a new slave <#{proxy_object.proxyable_type}> in `#{other_tenant}`"
    current_customer_id = Customer.id

    new_other_object = Apartment::Tenant.process(other_tenant) do
      
      # Create the object
      log proxy_object.id, "New attributes: #{new_attributes.inspect}"
      obj = proxy_object.proxyable_type.constantize.create(new_attributes)
      log(proxy_object.id, obj.errors.inspect) unless obj.valid?
      
      # Create the slave proxy
      obj.proxies.slave.create(
        other_customer_id: current_customer_id,
        other_id: proxy_object.id
      )

      return obj
    end
        
    proxy_object.update_attribute(:other_id, new_other_object.try(:id))
  end

  # Updates the slave object with new attributes.
  def update_slave(proxy_object, new_attributes, other_tenant)
    Apartment::Tenant.process(other_tenant) do

      # Find the slave object in the other tenant.
      log proxy_object.id, "We need to update the slave <#{proxy_object.proxyable_type} id:#{proxy_object.other_id}> in `#{other_tenant}`"
      slave_object = proxy_object.proxyable_type.constantize.find(proxy_object.other_id)

      # Update the attributes of the slave object using the attributes from the master object.
      log proxy_object.id, "New attributes: #{new_attributes.inspect}"
      slave_object.update_attributes(new_attributes)
      
    end
  end

  def log(id, message)
    Rails.logger.info { "[MultitenantProxy #{id}] #{message}"}
  end

end
