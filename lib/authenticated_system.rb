module AuthenticatedSystem
  protected
    # Returns true or false if the user is logged in.
    # Preloads @current_user with the user model if they're logged in.
    def logged_in?(required_identity = nil)
      # logger.info { "logged_in?() -- required_identity: #{required_identity}" }
      current_user(required_identity) != :false
    end
    
    # Accesses the current user from the session.  Set it to :false if login fails
    # so that future calls do not hit the database.
    def current_user(required_identity = nil)
      # logger.info { "#{controller_name}#current_user() -- required_identity: #{required_identity}" }
      @current_user ||= (login_from_vicarious || login_from_session || login_from_cookie || login_from_pubcookie(required_identity) || :false)
    end
    
    # Store the given user in the session.
    def current_user=(new_user)
      session[:user] = (new_user.nil? || new_user.is_a?(Symbol)) ? nil : new_user.id
      # LoginHistory.login(new_user)
      @current_user = new_user
    end
    
    # Check if the user is authorized
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the user
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorized?
    #    current_user.login != "bob"
    #  end
    def authorized?(required_identity = nil)
      # logger.info { "authorized?() -- required_identity: #{required_identity}" }
      logged_in?(required_identity)
    end

    # Filter method to enforce a login requirement.
    #
    # To require logins for all actions, use this in your controllers:
    #   before_filter :login_required
    #
    # To require logins for specific actions, use this in your controllers:
    #   before_filter :login_required, :only => [ :edit, :update ]
    #
    # To skip this in a subclassed controller:
    #   skip_before_filter :login_required
    #
    def login_required
      authorized? || access_denied
    end
    
    # Filter method to enforce a login requirement. Requires that the user is a student.
    def student_login_required
      authorized?('Student') || access_denied
    end
    
    # Filter method to enforce a login requirement. Requires that the user is logged in as a Student if a student record
    # exists for the person. Otherwise, allow them to login as a normal non-Student user.
    def student_login_required_if_possible
      authorized?('Student') || authorized? || access_denied
    end

    # Returns true if the current user is an admin user and deny access if not.
    def admin_required
      current_user.admin? || access_denied("You must be an admin user to access that page. Please login as an admin user.")
    end

    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the user is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    def access_denied(message = nil)
      flash[:error] = message unless message.blank?
      respond_to do |accepts|
        accepts.html do
          store_location
          redirect_to :controller => '/session', :action => 'new'
        end
        accepts.xml do
          headers["Status"]           = "Unauthorized"
          headers["WWW-Authenticate"] = %(Basic realm="Web Password")
          render :text => "Could't authenticate you", :status => '401 Unauthorized'
        end
      end
      false
    end  
    
    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
      session[:return_to] = request.request_uri
    end
    
    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end
    
    # Inclusion hook to make #current_user and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_user, :logged_in?, :vicarious_user, :vicariously_logged_in?
    end

    # Called from #current_user. If we have a valid vicarious user defined in our session, use that.
    def login_from_vicarious
      if session[:vicarious_user]
        vicarious_user = User.find_by_id(session[:vicarious_user])
        if vicarious_user.token == session[:vicarious_token]
          self.current_user = vicarious_user
        else
          HoptoadNotifier.notify(
            :error_class => "Vicarious Login Error",
            :error_message => "Vicarious Login Error: Vicarious token does not match",
            :parameters => params
          )
          clear_vicarious_user
          login_from_session
        end
      end
    end

    def clear_vicarious_user
      session[:user] = session[:original_user]
      session[:vicarious_user] = nil
      session[:original_user] = nil
      session[:vicarious_token] = nil
      self.current_user = nil
    end

    def vicariously_logged_in?
      !session[:vicarious_user].nil?
    end

    # Called from #current_user.  First attempt to login by the user id stored in the session.
    def login_from_session
      self.current_user = User.find_by_id(session[:user]) if session[:user]
    end

    # Called from #current_user.  Now, attempt to login by basic authentication information.
    def login_from_basic_auth
      username, passwd = get_auth_data
      self.current_user = User.authenticate(username, passwd) if username && passwd
    end
    
    # Called from #current_user. Now, try to get the Pubcookie login info from basic auth
    def login_from_pubcookie(require_identity = nil)
      # logger.info { "login_from_pubcookie() -- required_identity: #{require_identity}" }
      uwnetid, passwd = get_auth_data
      # logger.info "uwnetid #{uwnetid} detected in HTTP_AUTHORIZATION -- required identity: #{require_identity}" if uwnetid
      # LoginHistory.login(PubcookieUser.authenticate(uwnetid, passwd, require_identity), (request.env["HTTP_X_FORWARDED_FOR"] || request.env["REMOTE_ADDR"]), session.session_id) if uwnetid
      self.current_user = PubcookieUser.authenticate(uwnetid, passwd, require_identity) if uwnetid
    end

    # Called from #current_user.  Finally, attempt to login by an expiring token in the cookie.
    def login_from_cookie 
      user = cookies[:auth_token] && User.find_by_remember_token(cookies[:auth_token])
      if user && user.remember_token?
        user.remember_me
        cookies[:auth_token] = { :value => user.remember_token, :expires => user.remember_token_expires_at }
        self.current_user = user
      end
    end

  private
    @@http_auth_headers = %w(X-HTTP_AUTHORIZATION HTTP_AUTHORIZATION Authorization)
    # def get_auth_data
    #   auth_key  = @@http_auth_headers.detect { |h| request.env.has_key?(h) }
    #   auth_data = request.env[auth_key].to_s.split unless auth_key.blank?
    #   return auth_data && auth_data[0] == 'Basic' ? Base64.decode64(auth_data[1]).split(':')[0..1] : [nil, nil] 
    # end
    def get_auth_data
      [request.env["eppn"].split("@").first, nil] rescue [nil, nil]
    end
    
end
