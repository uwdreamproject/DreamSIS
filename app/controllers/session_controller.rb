# This controller handles the login/logout function of the site.  
class SessionController < ApplicationController
  skip_before_filter :login_required, :check_authorization, :check_for_limited_login, :check_if_enrolled, :authenticated?, :save_user_in_current_thread
  before_filter :login_required, :only => [ :map_to_person ]
  before_filter :apply_customer_styles

  def new
    redirect_to locator_url(:subdomain => false) if Customer.current_customer.nil? || Customer.current_customer.new_record?
    redirect_to "/auth/#{Customer.allowable_login_methods_list.first}" if Customer.allowable_login_methods_list.size == 1 && session[:external_login_context] != :rsvp
  end
  
  def locator
    @body_class = "new session"
    
    unless params[:url_shortcut].blank?
      if Customer.where(:url_shortcut => params[:url_shortcut]).empty?
        flash[:error] = "That organization does not exist. Please try again."
      else
        redirect_to root_url(:subdomain => params[:url_shortcut])
      end
    end
  end
  
  def create
    return_to = session[:return_to]
    reset_session
    auth = request.env["omniauth.auth"]
    if auth["provider"] == "shibboleth"
      attach_mentor_record = session[:external_login_context].nil? ? true : false
      user = PubcookieUser.authenticate(auth[:info][:email][/[^@]+/], nil, nil, attach_mentor_record)
    else
      user = User.find_by_provider_and_uid(auth["provider"], auth["uid"]) || User.create_with_omniauth(auth, request.subdomain)
      user.update_avatar_from_provider!(auth) if user
    end
    return redirect_to(login_url, :error => "Could not login. Please try again.") unless user
    session[:user_id] = user.id
    flash[:notice] = "Signed in!"
    redirect_back_or_default(return_to || root_url)
  end
  
  def create_anonymous
    user = AnonymousUser.create_random
    session[:user_id] = user.id
    # flash[:notice] = "Signed in!"
    redirect_back_or_default(root_url)
  end

  def destroy
    session[:user_id] = nil
    cookies.delete :auth_token
    reset_session
    redirect_to login_url, :notice => "Signed out!"
  end
  
  def identity_login
    @body_class = "new session"
  end
  
  def identity_register
    flash[:error] = "Sorry, you can't register for a new account directly."
    redirect_to '/auth/identity'
  end
  
  def map_login
    session[:user_id] = nil
    cookies.delete :auth_token
    reset_session
    
    @person = Person.find(params[:person_id])
    if @person.correct_login_token?(params[:token])
      flash[:info] = "Please login so that we can link your account."
      redirect_to login_url(:return_to => map_to_person_url(@person, params[:token]))
    else
      flash[:error] = "Sorry, but that login token is invalid. Please talk to your program administrator."
      redirect_to login_url
    end
  end

  def map_to_person
    @person = Person.find(params[:person_id])
    if @person.correct_login_token?(params[:token])
      if @current_user.update_attribute(:person_id, @person.id)
        @person.invalidate_login_token!
        flash[:notice] = "Your user account has been successfully linked to #{ActionController::Base.helpers.sanitize(@person.fullname)}."
        redirect_to root_url
      else
        render_error "Your user account could not be linked successfully."
      end
    else
      render_error "Invalid login token."
    end
  end

  def failure
    message = case params[:message]
      when "invalid_credentials" then "That username or password is incorrect."
      else "There was an error while trying to log you in."
    end
    flash[:error] = "#{message} Please try again or come back later."
    redirect_to login_url
  end

end
