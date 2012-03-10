class UwWebServiceConnection < ActiveResource::Connection

  cattr_accessor :debug
  attr_accessor :caller_class

  # Execute a GET request.
  # Used to get (find) resources.
  def get(path, headers = {})
    begin
      body = nil
      time = Benchmark::realtime { body = request(:get, path, build_request_headers(headers, :get)).body }
      sws_log "GET #{path}", time
      body
    rescue
      nil
    end
  end

  private

    def http
      configure_http(new_http_with_debug)
    end

    def new_http_with_debug
      h = new_http
      h.set_debug_output(debug == true ? $stderr : nil)
      h
    end
    
    def sws_log(msg, time = nil)
      caller_class_s = caller_class.to_s == "Class" ? self.class.to_s : (caller_class.to_s || self.class.to_s)
      message = "  \e[4;33;1m#{caller_class_s} Fetch"
      message << " (#{'%.1f' % (time*1000)}ms)" if time
      message << "\e[0m   #{msg}"
      RAILS_DEFAULT_LOGGER.info message
    end
  
end