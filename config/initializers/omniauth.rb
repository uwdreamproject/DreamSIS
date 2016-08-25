OmniAuth.config.logger = Rails.logger
omniauth_keys = API_KEYS["omniauth"]

Dreamsis::Application.config.middleware.use OmniAuth::Builder do
  provider :facebook, omniauth_keys["facebook"]["key"], omniauth_keys["facebook"]["secret"], 
    secure_image_url: true, scope: 'public_profile,email', client_options: {
    site: 'https://graph.facebook.com/v2.0',
    authorize_url: "https://www.facebook.com/v2.0/dialog/oauth"
  }
  provider :twitter, omniauth_keys["twitter"]["key"], omniauth_keys["twitter"]["secret"]
  provider :google_oauth2, omniauth_keys["google"]["key"], omniauth_keys["google"]["secret"]
  provider :google_oauth2, omniauth_keys["google"]["key"], omniauth_keys["google"]["secret"], { hd: "uw.edu", name: "shibboleth" }
  provider :windowslive, omniauth_keys["windowslive"]["key"], omniauth_keys["windowslive"]["secret"], scope: 'wl.basic'
  provider :linkedin, omniauth_keys["linkedin"]["key"], omniauth_keys["linkedin"]["secret"]
  provider :identity, fields: [:email], 
    on_login: lambda { |e| SessionController.action(:identity_login).call(e) },
    on_registration: SessionController.action(:identity_register),
    on_failed_registration: SessionController.action(:identity_register)

  
end

