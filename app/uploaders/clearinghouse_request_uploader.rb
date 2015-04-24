class ClearinghouseRequestUploader < CarrierWave::Uploader::Base

  storage :fog

  # def initialize(request_id)
  #   @request_id = request_id
  #   super
  # end

  def store_dir
    "uploads/nsc/#{@model}"
  end

  def cache_dir
    "#{Rails.root}/tmp/" + store_dir
  end

end
