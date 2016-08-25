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
        cert: OpenSSL::X509::Certificate.new(File.open(File.join(ENV['SHARED_CONFIG_ROOT'] || "#{Rails.root}/config", "certs", config_options[:cert]))),
        key: OpenSSL::PKey::RSA.new(File.open(File.join(ENV['SHARED_CONFIG_ROOT'] || "#{Rails.root}/config", "certs", config_options[:key]))),
        ca_file: File.join(ENV['SHARED_CONFIG_ROOT'] || "#{Rails.root}/config", "certs", config_options[:ca_file]),
        verify_mode: OpenSSL::SSL::VERIFY_PEER
      }
    end

    # All configuration options are stored in Rails.root/config/web_services.yml. This allows us to use different
    # hosts, certs, etc. in different Rails environments.
    def global_config_options
      config_file_path = "#{Rails.root}/config/web_services.yml"
      @global_config_options ||= YAML.load_file(config_file_path)[Rails.env]
    end
    
    # Returns config options for the current Tenant.
    def config_options
      tenant_options = global_config_options["tenant_options"][Customer.current_customer.url_shortcut]
      if tenant_options.nil?
        return {}
      else
        tenant_options.tap{ |t| t[:host] = global_config_options["host"] }.symbolize_keys
      end
    end

    def headers
      { "x-uw-act-as" => config_options[:act_as_user] }
    end  

    def sws_log(msg, method = "Fetch", time = nil)
      caller_class_s = caller_class.to_s == "Class" ? self.class.to_s : (caller_class.to_s || self.class.to_s)
      message = "  \e[4;33;1m#{caller_class_s} #{method}"
      message << " (#{'%.1f' % (time*1000)}ms)" if time
      message << "\e[0m   #{msg}"
      Rails.logger.info message
    end
        
  end

  self.site = "https://#{UwWebResource.global_config_options["host"]}" if UwWebResource.global_config_options["host"]
  
  protected
  
  # Raises an error if the cert, key, or CA file does not exist.
  def self.check_cert_paths!
    raise ActiveResource::SSLError, "Could not find cert file" unless File.exist?(File.join(ENV['SHARED_CONFIG_ROOT'] || "#{Rails.root}/config", "certs", config_options[:cert]))
    raise ActiveResource::SSLError, "Could not find key file" unless File.exist?(File.join(ENV['SHARED_CONFIG_ROOT'] || "#{Rails.root}/config", "certs", config_options[:key]))
    raise ActiveResource::SSLError, "Could not find CA file" unless File.exist?(File.join(ENV['SHARED_CONFIG_ROOT'] || "#{Rails.root}/config", "certs", config_options[:ca_file]))
    return true
  rescue => e
    puts Rails.logger.warn "[WARN] ActiveResource::SSLError: #{e.message}\n #{e.backtrace.try(:first)}"
    return false
  end
  
end
