Apartment.configure do |config|
  config.excluded_models = ["Customer", "Identity"]
  config.tenant_names = lambda{ Customer.all.collect(&:tenant_name) }
  # config.prepend_environment = true
end

Apartment::Elevators::Subdomain.excluded_subdomains = Customer::RESERVED_SUBDOMAINS