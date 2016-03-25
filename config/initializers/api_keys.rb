s3 = Aws::S3::Client.new
resp = s3.get_object( bucket: ENV['S3_BUCKET_NAME'], key: ENV['API_KEYS_PATH'] )
API_KEYS = YAML::load(resp.body.read)