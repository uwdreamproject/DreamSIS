config_file_path = "#{RAILS_ROOT}/config/omniauth_keys.yml"
omniauth_keys = YAML::load(ERB.new((IO.read(config_file_path))).result)

ActionController::Dispatcher.middleware.use OmniAuth::Builder do
  provider :facebook, omniauth_keys["facebook"]["key"], omniauth_keys["facebook"]["secret"], :secure_image_url => true
  provider :twitter, omniauth_keys["twitter"]["key"], omniauth_keys["twitter"]["secret"]
  provider :google_oauth2, omniauth_keys["google"]["key"], omniauth_keys["google"]["secret"]
  provider :shibboleth, :extra_fields => [:"unscoped-affiliation", :entitlement, :gws_groups, :uwNetID, :uwRegID]
  # provider :identity #, :on_failed_registration => SessionController.call("signup")
end