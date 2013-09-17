# Writes the newrelic config file to /config/newrelic.yml and then loads the config file through NewRelic.
# config_file_path = File.join(ENV['SHARED_CONFIG_ROOT'] || "#{RAILS_ROOT}/config", "newrelic.yml")
# File.open(config_file_path, 'w') {|f| f.write("
# common: &default_settings
#   license_key: '#{API_KEYS["newrelic"][RAILS_ENV]["license_key"]}'
#   app_name: '#{API_KEYS["newrelic"][RAILS_ENV]["app_name"]}'
#   monitor_mode: true
#   developer_mode: false
#   log_level: info
#   ssl: true
#   capture_params: false
# 
# development:
#   <<: *default_settings
#   monitor_mode: false
#   developer_mode: true
# 
# test:
#   <<: *default_settings
#   monitor_mode: false
# 
# production:
#   <<: *default_settings
#   monitor_mode: true
# 
# staging:
#   <<: *default_settings
#   monitor_mode: true
# ") }
# 
# `NEWRELIC_ENABLE=true rake assets:precompile`