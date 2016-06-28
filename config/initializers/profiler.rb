Rack::MiniProfiler.config.storage = Rack::MiniProfiler::FileStore
Rack::MiniProfiler.config.disable_caching = false

if Rails.env.production?  
  endpoint = API_KEYS["redis"][Rails.env]["endpoint"]
  password = API_KEYS["redis"][Rails.env]["password"]
  uri = URI.parse("redis://#{endpoint}")
  Rack::MiniProfiler.config.storage_options = { host: uri.host, port: uri.port, password: password }
  Rack::MiniProfiler.config.storage = Rack::MiniProfiler::RedisStore
end