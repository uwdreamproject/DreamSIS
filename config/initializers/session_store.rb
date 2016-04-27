endpoint = API_KEYS["redis"][Rails.env]["endpoint"]
password = API_KEYS["redis"][Rails.env]["password"]

Dreamsis::Application.config.session_store :redis_store, 
  servers: { url: "redis://#{endpoint}", password: password, namespace: "session" }, 
  expires_in: 8.hours

Dreamsis::Application.config.action_dispatch.rack_cache = {
  meta_store: { url: "redis://#{endpoint}", network_timeout: 5, password: password, namespace: "meta_store" },
  entity_store: { url: "redis://#{endpoint}", network_timeout: 5, password: password, namespace: "entity_store" }
}
