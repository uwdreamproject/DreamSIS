# CarrierWave.configure do |config|
#   config.s3_access_key_id = API_KEYS['s3'][Rails.env]['access_key_id']
#   config.s3_secret_access_key = API_KEYS['s3'][Rails.env]['secret_access_key']
#   config.s3_bucket = API_KEYS['s3'][Rails.env]['bucket']
#   config.s3_access = :private
# end

CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',
    :aws_access_key_id      => API_KEYS['s3'][Rails.env]['access_key_id'],
    :aws_secret_access_key  => API_KEYS['s3'][Rails.env]['secret_access_key'],
    :region                 => 'us-west-1',                  # optional, defaults to 'us-east-1'
  }
  config.fog_directory  = API_KEYS['s3'][Rails.env]['bucket']
  config.fog_public     = false
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}
end
