# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
# ActionController::Base.cookie_verifier_secret = 'd35820ca9ad1dc1d33b0ceff41db49ac46c28b3b05893a9a55469f460fd936b96d98936c2b886fde428368b1dc1338e3fbf687e6ac8633b5ccab4c4c5b760b1b';


require 'cgi'
require 'cgi/session'
class CGI::Session::CookieStore
  # Restore session data from the cookie.
  # This method overrides the one in 
  # actionpack/lib/action_controller/session/cookie_store.rb
  # in order to handle the case of a "tampered" cookie more gracefully.
  # The issue is that changing the 'secret' in config/environment.rb
  # breaks all sessions in such a way that everyone gets an error page
  # the first time they revisit the site.  Catching the exception here
  # prevents this ugly behavior.
  # This is in a plugin so that it loads after Rails but before environment.rb.
  def restore
    @original = read_cookie
    @data = unmarshal(@original) || {}
  rescue CGI::Session::CookieStore::TamperedWithCookie
    logger = Logger.new("#{RAILS_ROOT}/log/#{RAILS_ENV}.log")
    logger.warn "Caught TamperedWithCookie exception on #{Time.now}"
    @data = {}
  end
end
