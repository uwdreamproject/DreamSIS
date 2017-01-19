Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'], network_timeout: 5, size: 5 }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'], network_timeout: 5, size: 5 }
end

# Make generic redis available for other purposes
$redis = Redis::Namespace.new("default", :redis => Redis.new({ url: ENV['REDIS_URL'], network_timeout: 5, size: 5 }))
$redis.client.logger = Rails.logger
