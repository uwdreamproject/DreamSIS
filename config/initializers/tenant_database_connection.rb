# require 'apartment/adapters/abstract_adapter'
#
# Apartment::Adapters::AbstractAdapter.class_eval do
#
#   protected
#
#   # Override Apartment's multi_tenantify method to inject other configuration options as needed.
#   def multi_tenantify(tenant)
#     @config.clone.tap do |config|
#       config[:database] = environmentify(tenant)
#       config[:host] = "test.local"
#       # adjust other settings here based on Customer
#     end
#   end
#
# end
