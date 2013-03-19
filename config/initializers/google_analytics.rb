# You should store your google API tracking code in RAILS_ROOT/config/google_analytics.yml.

config_file_path = File.join(ENV['SHARED_CONFIG_ROOT'] || "#{RAILS_ROOT}/config", "google_analytics.yml")
GOOGLE_ANALYTICS_TRACKING_ID = YAML::load(ERB.new((IO.read(config_file_path))).result)[RAILS_ENV]
