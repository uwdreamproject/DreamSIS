class ReportUploader < CarrierWave::Uploader::Base
  
  storage :fog

  def store_dir
    ["uploads", model.tenant, model.class.to_s.underscore, model.id].compact.join("/")
  end

  def move_to_cache
    false
  end


end
