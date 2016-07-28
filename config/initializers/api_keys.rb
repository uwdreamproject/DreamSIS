local_file_path = File.join(ENV['SHARED_CONFIG_ROOT'] || "#{Rails.root}/config", "api-keys.yml")

# Load the API keys config file from S3 if we can
if ENV['S3_BUCKET_NAME'] && ENV['API_KEYS_PATH']
  s3 = Aws::S3::Client.new
  resp = s3.get_object( bucket: ENV['S3_BUCKET_NAME'], key: ENV['API_KEYS_PATH'] )
  API_KEYS = YAML::load(resp.body.read)
  Rails.logger.info { "Successfully loaded keys from S3" }

# Otherwise, try to load it locally.
elsif File.exist?(local_file_path)
  API_KEYS = YAML::load(ERB.new((IO.read(local_file_path))).result)
  Rails.logger.info { "Successfully loaded keys from #{local_file_path}"}

# Otherwise, kill the startup because we have a problem.
else
  raise "Could not load keys file."
end
