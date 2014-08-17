# Writes the exceptional config file to /config/exceptional.yml and then loads the config file through Exceptional.
config_file_path = File.join(ENV['SHARED_CONFIG_ROOT'] || "#{Rails.root}/config", "exceptional.yml")
File.open(config_file_path, 'w') {|f| f.write("api-key: #{API_KEYS['exceptional']['api_key']}") }
Exceptional::Config.load(config_file_path)