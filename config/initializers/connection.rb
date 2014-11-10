# Uncomment this file if you want to see ActiveResource debug output when you make requests.
 
  class ActiveResource::Connection
    def configure_http(http)
      http = apply_ssl_options(http)
  
      # Net::HTTP timeouts default to 60 seconds.
      if @timeout
        http.open_timeout = @timeout
        http.read_timeout = @timeout
      end
  
      http.set_debug_output $stderr # send our debug output to the console
      http.ssl_version = :TLSv1_2
  
      http
    end
  
  end
