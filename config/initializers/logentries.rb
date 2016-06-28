if API_KEYS["logentries"]
  token = API_KEYS["logentries"][Rails.env]["default"]
  Rails.logger = Le.new(token, debug: true, local: true, ssl: true, tag: true)
  
  # Tag log entries with the server ID and the rails environment
  server_id_path = File.join(Rails.root, "config", "server_id.txt")
  server_id = File.exist?(server_id_path) ? File.read(server_id_path).strip : Socket.gethostname
  Dreamsis::Application.config.log_tags = [:host, server_id]
end