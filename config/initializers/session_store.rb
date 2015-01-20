# Be sure to restart your server when you modify this file.

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
Dreamsis::Application.config.session_store :cookie_store, :domain => :all, :tld_length => 2

# ActionController::Base.session = {
#   :key         => '_dreamsis_session',
#   :secret      => ActiveSupport::SecureRandom.hex(64)
# }

