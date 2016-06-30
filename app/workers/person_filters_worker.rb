class PersonFiltersWorker
  include Sidekiq::Worker

  # Refresh the filter cache for this person (or people, if multiple ID's are passed).
  def perform(person_id, tenant_name = Apartment::Tenant.current)
    begin
      ActiveRecord::Base.connection_pool.with_connection do
        Apartment::Tenant.switch(tenant_name)
        person = Person.where(id: person_id)
        person.collect(&:update_filter_cache!)
      end
    rescue => e
      Rails.logger.error { "[PersonFiltersWorker] ERROR: #{e.message}" }
      Rollbar.error(e, :person_id => person_id)
    end
  end

end
