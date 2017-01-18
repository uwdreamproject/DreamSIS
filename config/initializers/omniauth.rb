OmniAuth.config.logger = Rails.logger
omniauth_keys = API_KEYS["omniauth"]

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, omniauth_keys["facebook"]["key"], omniauth_keys["facebook"]["secret"],
    secure_image_url: true, scope: 'public_profile,email'
  provider :twitter, omniauth_keys["twitter"]["key"], omniauth_keys["twitter"]["secret"]
  provider :google_oauth2, omniauth_keys["google"]["key"], omniauth_keys["google"]["secret"]
  provider :google_oauth2, omniauth_keys["google"]["key"], omniauth_keys["google"]["secret"], { hd: "uw.edu", name: "shibboleth" }
  provider :identity, fields: [:email],
    on_login: lambda { |e| SessionController.action(:identity_login).call(e) },
    on_registration: SessionController.action(:identity_register),
    on_failed_registration: SessionController.action(:identity_register)

  
end
