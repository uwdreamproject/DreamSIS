config_file_path = File.join(ENV['SHARED_CONFIG_ROOT'] || "#{RAILS_ROOT}/config", "exceptional.yml")
Exceptional::Config.load(config_file_path)
