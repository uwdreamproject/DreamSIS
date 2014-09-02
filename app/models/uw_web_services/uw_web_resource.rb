class UwWebResource < ActiveResource::Base

  # Tries to fetch the requested attribute from the result payload.
  def attribute(*args)
    return nil unless attributes
    arg = args.first
    arg = "UWNetID" if arg.to_s == "uw_netid" || arg.to_s == "uw_net_id" || arg.to_s == "uwnetid"
    val = attributes[arg] || attributes[arg.to_s.camelize]
    return nil if val.respond_to?(:attributes) && val.try(:attributes).try(:[], "i:nil") == "true"
    return val
  end

  class << self

    attr_accessor :caller_class
  
    # Attaches our cert, key, and CA file based on the config options in web_services.yml.
    def ssl_options
      return {} unless check_cert_paths!
      @ssl_options ||= {
        :cert         => OpenSSL::X509::Certificate.new(File.open(File.join(ENV['SHARED_CONFIG_ROOT'] || "#{RAILS_ROOT}/config", "certs", config_options[:cert]))),
        :key          => OpenSSL::PKey::RSA.new(File.open(File.join(ENV['SHARED_CONFIG_ROOT'] || "#{RAILS_ROOT}/config", "certs", config_options[:key]))),
        :ca_file      => File.join(ENV['SHARED_CONFIG_ROOT'] || "#{RAILS_ROOT}/config", "certs", config_options[:ca_file]),
        :verify_mode  => OpenSSL::SSL::VERIFY_NONE
      }
    end

    # All configuration options are stored in RAILS_ROOT/config/web_services.yml. This allows us to use different
    # hosts, certs, etc. in different Rails environments.
    def config_options
      config_file_path = "#{RAILS_ROOT}/config/web_services.yml"
      @config_options ||= YAML::load(ERB.new((IO.read(config_file_path))).result)[(RAILS_ENV)].symbolize_keys
    end

    def headers
      { "x-uw-act-as" => config_options[:act_as_user] }
    end  

    def sws_log(msg, method = "Fetch", time = nil)
      caller_class_s = caller_class.to_s == "Class" ? self.class.to_s : (caller_class.to_s || self.class.to_s)
      message = "  \e[4;33;1m#{caller_class_s} #{method}"
      message << " (#{'%.1f' % (time*1000)}ms)" if time
      message << "\e[0m   #{msg}"
      RAILS_DEFAULT_LOGGER.info message
    end
        
  end

  self.site = "https://#{UwWebResource.config_options[:host]}"
  
  protected
  
  # Raises an error if the cert, key, or CA file does not exist.
  def self.check_cert_paths!
    raise ActiveResource::SSLError, "Could not find cert file" unless File.exist?(File.join(ENV['SHARED_CONFIG_ROOT'] || "#{RAILS_ROOT}/config", "certs", config_options[:cert]))
    raise ActiveResource::SSLError, "Could not find key file" unless File.exist?(File.join(ENV['SHARED_CONFIG_ROOT'] || "#{RAILS_ROOT}/config", "certs", config_options[:key]))
    raise ActiveResource::SSLError, "Could not find CA file" unless File.exist?(File.join(ENV['SHARED_CONFIG_ROOT'] || "#{RAILS_ROOT}/config", "certs", config_options[:ca_file]))
    return true
  rescue ActiveResource::SSLError => e
    puts Rails.logger.warn "[WARN] ActiveResource::SSLError: #{e.message}\n #{e.backtrace.try(:first)}"
    return false
  end
  
end
