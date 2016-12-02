local_file_path = File.join(ENV['SHARED_CONFIG_ROOT'] || "#{Rails.root}/config", "api-keys.yml")

# Otherwise, try to load it locally.
if File.exist?(local_file_path)
  API_KEYS = YAML::load(ERB.new((IO.read(local_file_path))).result)
  puts "Successfully loaded keys from #{local_file_path}"

# Load the API keys config file from S3 if we can
elsif ENV['S3_BUCKET_NAME'] && ENV['API_KEYS_PATH']
  s3 = Aws::S3::Client.new
  resp = s3.get_object( bucket: ENV['S3_BUCKET_NAME'], key: ENV['API_KEYS_PATH'] )
  API_KEYS = YAML::load(resp.body.read)
  puts "Successfully loaded keys from S3"

# Otherwise, kill the startup because we have a problem.
else
  raise "Could not load keys file."
end
