CarrierWave.configure do |config|
  config.s3_access_key_id = API_KEYS['s3'][RAILS_ENV]['access_key_id']
  config.s3_secret_access_key = API_KEYS['s3'][RAILS_ENV]['secret_access_key']
  config.s3_bucket = API_KEYS['s3'][RAILS_ENV]['bucket']
	config.s3_access = :private
end
