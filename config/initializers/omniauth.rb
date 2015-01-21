OmniAuth.config.logger = Rails.logger
omniauth_keys = API_KEYS["omniauth"]

Dreamsis::Application.config.middleware.use OmniAuth::Builder do
  provider :facebook, omniauth_keys["facebook"]["key"], omniauth_keys["facebook"]["secret"], 
    :secure_image_url => true,   :scope => 'public_profile,email', :provider_ignores_state => true, :client_options => {
    :site => 'https://graph.facebook.com/v2.0',
    :authorize_url => "https://www.facebook.com/v2.0/dialog/oauth"
  }
  provider :twitter, omniauth_keys["twitter"]["key"], omniauth_keys["twitter"]["secret"], :provider_ignores_state => true
  provider :google_oauth2, omniauth_keys["google"]["key"], omniauth_keys["google"]["secret"], :provider_ignores_state => true
  provider :google_oauth2, omniauth_keys["google"]["key"], omniauth_keys["google"]["secret"], {:hd => "uw.edu", :name => "shibboleth", :provider_ignores_state => true}
  provider :windowslive, omniauth_keys["windowslive"]["key"], omniauth_keys["windowslive"]["secret"], :scope => 'wl.basic', :provider_ignores_state => true
  provider :linkedin, omniauth_keys["linkedin"]["key"], omniauth_keys["linkedin"]["secret"], :provider_ignores_state => true
end

