require 'ERB'
require 'YAML'

on_app_master do
  config_file_path = File.join(config.shared_path, "config", "api-keys.yml")
  API_KEYS = YAML::load(ERB.new((IO.read(config_file_path))).result)
  access_token = API_KEYS["rollbar"]["server_side_access_token"]
  run "curl https://api.rollbar.com/api/1/deploy/ --silent -F access_token=#{access_token} -F environment=#{config.environment} -F revision=#{config.revision}"
end