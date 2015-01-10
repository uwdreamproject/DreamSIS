require 'yaml'

on_app_servers do
  config_file_path = File.join(config.shared_path, "config", "api-keys.yml")
  API_KEYS = YAML.load_file(config_file_path)
  access_token = API_KEYS["rollbar"]["server_side_access_token"]
  run "curl https://api.rollbar.com/api/1/deploy/ --silent -F access_token=#{access_token} -F environment=#{config.environment} -F revision=#{config.revision}"
end

on_app_servers do
  sudo "cd #{config.current_path} && bundle exec sidekiqctl stop #{config.shared_path}/pid/DreamSIS_sidekiq.pid"
  sudo "cd #{config.current_path} && bundle exec sidekiq -d -e #{config.environment} -l #{config.shared_path}/log/DreamSIS_sidekiq.log -P #{config.shared_path}/pid/DreamSIS_sidekiq.pid"
end