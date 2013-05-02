# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'd73a2fb5c7f692711c9685574a115b86'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  include AuthenticatedSystem #, ExceptionNotifiable
  require 'array_math'
  
  before_filter :authenticated?
  before_filter :login_required, :except => [ 'remove_vicarious_login' ]
  before_filter :save_user_in_current_thread
  before_filter :configure_exceptional
  # before_filter :set_stamper # part of Userstamp -- moved here so that it is called *after* the login process
  before_filter :save_return_to
  before_filter :check_authorization
  before_filter :check_if_enrolled

  after_filter :flash_to_headers
  
  helper_method :current_user

  def forbidden
  end

  # Add return_to to session if it's been requested
  def save_return_to
    session[:return_to] = params[:return_to] unless params[:return_to].blank?
    session[:return_to_after_profile] = params[:return_to_after_profile] unless params[:return_to_after_profile].blank?
  end

  def redirect_to_path
    new_path = session[:return_to]
    session[:return_to] = nil
    new_path || root_url
  end
  
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def local_request?
    false
  end
  # consider_local "172.28.99.10"

  protected
  
  def authenticated?
    @current_user ||= User.find session[:user_id] if session[:user_id]
    !@current_user.nil?
  end
  
  def login_required
    unless authenticated?
      session[:return_to] = request.request_uri
      return redirect_to(login_path)
    end
  end

  def check_authorization
    unless @current_user && (@current_user.admin? || (@current_user.person.try(:respond_to?, :current_lead?) && @current_user.person.try(:current_lead?)))
      render_error("You are not allowed to access that page.")
    end
  end

  def check_if_enrolled
    unless @current_user.admin? || !@current_user.is_a?(Mentor) || @current_user.person.currently_enrolled?
      if Term.allowing_signups.empty?
        render_error("You aren't signed up for the Dream Project and sign ups are disabled for now. Please come back later.")
      else
        return redirect_to(mentor_signup_path)
      end
    end
  end

  def render_error(error_message)
    @error_message = error_message
    @body_class = "error 403"
    return render(:template => "application/forbidden", :status => 403) unless performed?
  end

  def flash_to_headers
    if request.xhr?
      flash_json = Hash[flash.map{|k,v| [k,ERB::Util.h(v)] }].to_json
      response.headers['X-Flash-Messages'] = flash_json
      flash.discard
    end
  end

  private

  def save_user_in_current_thread
    Thread.current['user'] = @current_user
  end

  def apply_extra_stylesheet(extra_stylesheet = nil)
    if extra_stylesheet
      @extra_stylesheet = extra_stylesheet
      session[:extra_stylesheet] = @extra_stylesheet
    else
      @extra_stylesheet = session[:extra_stylesheet] unless session[:extra_stylesheet].blank?
    end
  end
  
  def apply_extra_footer_content(extra_footer_content = nil)
    if extra_footer_content
      @extra_footer_content = extra_footer_content
      session[:extra_footer_content] = @extra_footer_content
    else
      @extra_footer_content = session[:extra_footer_content] unless session[:extra_footer_content].blank?
    end
  end

  def apply_extra_styles_if_requested
    session[:apply_extra_styles] = params[:apply_extra_styles] if params[:apply_extra_styles]
    apply_extra_stylesheet if params[:apply_extra_styles] || session[:apply_extra_styles]
  end

  def apply_extra_footer_content_if_requested
    session[:apply_extra_footer_content] = params[:apply_extra_footer_content] if params[:apply_extra_footer_content]
    apply_extra_footer_content if params[:apply_extra_footer_content] || session[:apply_extra_footer_content]
  end
  
  def configure_exceptional
    # Exceptional.context( :user => @current_user.try(:login) )
  end

  def adjust_format_for_iphone
    session[:skip_mobile] = true if params[:skip_mobile] == "true"
    session[:skip_mobile] = nil if params[:skip_mobile] == "false"
    if iphone_request? && !session[:skip_mobile]
      request.format = :iphone
    end
  end

  def iphone_request?
    request.user_agent =~ /(Mobile\/.+Safari)/
  end
  helper_method :iphone_request?
  
end
