config_file_path = File.join(ENV['SHARED_CONFIG_ROOT'] || "#{RAILS_ROOT}/config", "cache.yml")
CACHE_CONFIG = YAML::load(ERB.new((IO.read(config_file_path))).result)
