class CollegeMapperResource < ActiveResource::Base

  def self.find(*args)
    sws_log args.inspect, "Find"
    super
  end
  
  def self.create(*args)
    sws_log args.inspect, "Create"
    super
  end

  def self.save(*args)
    sws_log args.inspect, "Save"
    super
  end

  def self.delete(*args)
    sws_log args.inspect, "Delete"
    super
  end

  
  class << self

    attr_accessor :caller_class
  
    # All configuration options are stored in Rails.root/config/web_services.yml. This allows us to use different
    # hosts, certs, etc. in different Rails environments.
    def config_options
      # config_file_path = File.join(ENV['SHARED_CONFIG_ROOT'] || "#{Rails.root}/config", "college_mapper.yml")
      # @config_options ||= YAML::load(ERB.new((IO.read(config_file_path))).result)[(Rails.env)].symbolize_keys      
      @config_options ||= API_KEYS['collegemapper'][Rails.env].symbolize_keys
    end

    def headers
      { 
        "X-Auth-Token" => config_options[:api_key],
        "Accept" => "*/*" # hack to prevent 406 errors from the CollegeMapper API
      }
    end  

    def sws_log(msg, method = "Fetch", time = nil)
      caller_class_s = caller_class.to_s == "Class" ? self.class.to_s : (caller_class.to_s || self.class.to_s)
      message = "  \e[4;33;1m#{caller_class_s} #{method}"
      message << " (#{'%.1f' % (time*1000)}ms)" if time
      message << "\e[0m   #{msg}"
      Rails.logger.info message
    end
        
  end

  self.site = CollegeMapperResource.config_options[:host]
  self.format = :json

end