endpoint = API_KEYS["redis"][Rails.env]["endpoint"]
password = API_KEYS["redis"][Rails.env]["password"]

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://#{endpoint}", network_timeout: 5, password: password }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://#{endpoint}", network_timeout: 5, password: password }
end
