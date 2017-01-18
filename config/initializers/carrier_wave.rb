CarrierWave.configure do |config|
  config.fog_credentials = {
    provider: 'AWS',
    aws_access_key_id: API_KEYS['s3'][Rails.env]['access_key_id'],
    aws_secret_access_key: API_KEYS['s3'][Rails.env]['secret_access_key'],
    region: API_KEYS['s3'][Rails.env]['region'],
    host: API_KEYS['s3'][Rails.env]['host'],
    endpoint: API_KEYS['s3'][Rails.env]['endpoint']
  }
  config.fog_directory  = lambda { API_KEYS['s3'][Rails.env]['bucket'] + "-" + (Apartment::Tenant.current || "default") }
  config.fog_public     = false
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}
  config.fog_use_ssl_for_aws = true
  config.enable_processing = true
  config.cache_dir = Rails.root.join('tmp')
  config.delete_tmp_file_after_storage = false
end
