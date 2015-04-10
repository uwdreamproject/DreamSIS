class AvatarUploader < CarrierWave::Uploader::Base

  # Include RMagick or ImageScience support
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader
  # storage :file
  storage :fog

  # Override the directory where uploaded files will be stored
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "#{Rails.root}/tmp/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def cache_dir
    store_dir
  end

  # Provide a default URL as a default if there hasn't been a file uploaded
  def default_url
    "/images/blank_avatar_" + version_name + ".png"
  end
  
  # Create different versions of your uploaded files	
	version :mini do
		process :resize_to_fill => [32, 32]
	end

  version :thumb do
    process :resize_to_fill => [50, 50]
  end

  version :small do
    process :resize_to_fill => [150, 150]
  end
	
	version :medium do
    process :resize_to_fill => [300, 300]
	end
  
  version :large do
    process :resize_to_limit => [600, 600]
  end

  # Add a white list of extensions which are allowed to be uploaded,
  # for images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files
  def filename
    "avatar.jpg" if original_filename
  end

end
