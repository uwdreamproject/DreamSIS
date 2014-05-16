class ReportUploader < CarrierWave::Uploader::Base
  
  storage :s3

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

end
