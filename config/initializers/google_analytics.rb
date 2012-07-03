# You should store your google API tracking code in RAILS_ROOT/config/google_analytics.yml.

config_file_path = "#{RAILS_ROOT}/config/google_analytics.yml"
@google_api_tracking_id ||= YAML::load(ERB.new((IO.read(config_file_path))).result)[:tracking_id]
