class DocumentUploader < CarrierWave::Uploader::Base
  include CarrierWave::Compatibility::Paperclip

  storage :fog

  process :save_content_type_and_size_in_model

  def save_content_type_and_size_in_model
    model.document_content_type = file.content_type if file.content_type
    model.document_file_size = file.size
  end

  # Override the directory where uploaded files will be stored
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Override the filename of the uploaded files
  # def filename
  #   model.title.to_param if original_filename
  # end

end
