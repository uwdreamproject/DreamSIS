class ReportUploader < CarrierWave::Uploader::Base
  
  storage :fog

  def store_dir
    ["uploads", model.tenant, model.class.to_s.underscore, model.id].compact.join("/")
  end

  def cache_dir
    Rails.root.join('tmp')
  end
  
  def move_to_cache
    true
  end


end
