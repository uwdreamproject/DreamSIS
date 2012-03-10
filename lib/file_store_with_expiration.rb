# From http://www.shaldybin.com/2009/05/how-to-cache-lot-of-rarely-changing.html
class FileStoreWithExpiration < ActiveSupport::Cache::FileStore

  def read(name, options = nil)
    expires_in = options.is_a?(Hash) && options.has_key?(:expires_in) ? options[:expires_in] : 0
    file_path = real_file_path(name)
    return if expires_in > 0 && File.exists?(file_path) && (File.mtime(file_path) < (Time.now - expires_in))
    super
  end
  
end