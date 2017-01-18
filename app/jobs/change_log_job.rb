class ChangeLogJob < ApplicationJob
  queue_as :default

  def perform(action_type, record_class, record_id, changes, user_id, tenant_name = Apartment::Tenant.current)
    begin
      ActiveRecord::Base.connection_pool.with_connection do
        Apartment::Tenant.switch!(tenant_name)
        Change.log_change(action_type, record_class, record_id, changes, user_id)
      end
    rescue => e
      Rails.logger.error { "[PersonFiltersJob] ERROR: #{e.message}" }
      Rollbar.error(e)
    end

  end
end
