# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_dreamsis_session',
  :secret      => '1e1972b7c416b67bbf088af3232172fe882a24ed9cd38e5cb5f322dda4beab919d7b9b13fd1ac183a269087d6137b8661fd33d7e01beef1d88003579d6277480'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
