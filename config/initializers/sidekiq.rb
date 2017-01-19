Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] }
end

# Make generic redis available for other purposes
$redis = Redis::Namespace.new("default", :redis => Redis.new(
  { url: ENV['REDIS_URL'] })
)
$redis.client.logger = Rails.logger
