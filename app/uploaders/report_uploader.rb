class ReportUploader < CarrierWave::Uploader::Base
  
  storage :fog

  def store_dir
    "#{Rails.root}/tmp/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def cache_dir
    store_dir
  end


end
