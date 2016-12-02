Dreamsis::Application.config.session_store :redis_store,
  servers: { url: ENV['REDIS_URL'], namespace: "session" },
  expires_in: 8.hours

Dreamsis::Application.config.action_dispatch.rack_cache = {
  meta_store: { url: ENV['REDIS_URL'], network_timeout: 5, namespace: "meta_store" },
  entity_store: { url: ENV['REDIS_URL'], network_timeout: 5, namespace: "entity_store" }
}
