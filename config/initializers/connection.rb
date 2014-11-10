# Uncomment this file if you want to see ActiveResource debug output when you make requests.

# Also modifies connection to force use of TLS
  class ActiveResource::Connection
    def configure_http(http)
      http = apply_ssl_options(http)
  
      # Net::HTTP timeouts default to 60 seconds.
      if @timeout
        http.open_timeout = @timeout
        http.read_timeout = @timeout
      end
  
      http.set_debug_output $stderr if Rails.env.eql? "development"
 
      http.ssl_version = :TLSv1
  
      http
    end
  
  end
