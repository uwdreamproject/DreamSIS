# You should store your google API tracking code in Rails.root/config/google_analytics.yml.

# config_file_path = File.join(ENV['SHARED_CONFIG_ROOT'] || "#{Rails.root}/config", "google_analytics.yml")
# GOOGLE_ANALYTICS_TRACKING_ID = YAML::load(ERB.new((IO.read(config_file_path))).result)[Rails.env]
GOOGLE_ANALYTICS_TRACKING_ID = API_KEYS['google_analytics']['account_id']