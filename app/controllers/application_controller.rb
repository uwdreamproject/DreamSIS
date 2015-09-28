class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery
  
  require 'array_math'

  before_filter :reset_tenant_if_admin_subdomain
  before_filter :authenticated?, :except => %w[ ping ]
  before_filter :login_required, :except => [ 'remove_vicarious_login', 'ping' ]
  before_filter :save_user_in_current_thread, :except => %w[ ping ]
  before_filter :save_return_to, :except => %w[ ping ]
  before_filter :check_authorization, :except => %w[ ping ]
  before_filter :check_if_enrolled, :except => %w[ ping ]
  after_filter :flash_to_headers, :except => %w[ ping ]
  
  helper_method :current_user
  
  def current_user
    @current_user
  end

  def forbidden
    # render forbidden.html.erb
  end
  
  def ping
    render :text => "200 OK", :status => :ok
  end
  
  def sidekiq_status
    statusHash = { :process_size => Sidekiq::ProcessSet.new.size }
    render :json => statusHash, :status => (statusHash[:process_size] > 0 ? :ok : :not_found)
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

  protected

  def authenticated?
    @current_user ||= User.find(session[:user_id]) if session[:user_id] rescue nil
    !@current_user.nil?
  end
  
  def login_required
    unless authenticated?
      session[:return_to] = request.url
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
        render_error("You aren't signed up for the #{Customer.name_label} and sign ups are disabled for now. Please come back later.")
      else
        return redirect_to(mentor_signup_path)
      end
    end
  end

  def render_error(error_message, error_title = nil, status = 403)
    status = 403 unless [403, 400].include?(status)
    @error_title = error_title || "You aren't allowed to access that page."
    @error_message = error_message
    @body_class = "error #{status}"
    return render(:template => "application/forbidden", :status => status) unless performed?
  end

  def flash_to_headers
    if request.xhr?
      flash_json = Hash[flash.map{|k,v| [k,ERB::Util.h(v)] }].to_json
      response.headers['X-Flash-Messages'] = flash_json
      flash.discard
    end
  end

  private

  def reset_tenant_if_admin_subdomain
    Apartment::Tenant.reset if request.subdomain == 'admin' || !request.subdomain.present?
  end

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
  
  def apply_customer_styles
    @customer_stylesheet = Customer.stylesheet_url if Customer.stylesheet_url
  end
    
end
