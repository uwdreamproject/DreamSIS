# This controller handles the login/logout function of the site.  
class SessionController < ApplicationController
  skip_before_filter :login_required, :check_authorization, :check_for_limited_login, :check_if_enrolled
  before_filter :fetch_customer
  before_filter :login_required, :only => [ :map_to_person ]

  # render new.rhtml
  def new
  end
  
  def signup
    @identity = request.env["omniauth.identity"]
  end

  # def create
  #   if params[:uwnetid_button]
  #     uwnetid_authentication
  #     return
  #   end
  #   password_authentication(params[:login], params[:password])
  # end
  # 
  # def destroy
  #   self.current_user.forget_me if logged_in?
  #   cookies.delete :auth_token
  #   reset_session
  #   flash[:notice] = "You have been logged out."
  #   redirect_back_or_default('/')
  # end


  def create
    auth = request.env["omniauth.auth"]
    # raise auth.to_yaml
    if auth["provider"] == "shibboleth"
      attach_mentor_record = session[:external_login_context].nil? ? true : false
      user = PubcookieUser.authenticate(auth["uid"], nil, nil, attach_mentor_record)
      return redirect_to login_url, :error => "Could not login. Please try again." unless user
    else
      user = User.find_by_provider_and_uid_and_customer_id(auth["provider"], auth["uid"], Customer.current_customer.id) || User.create_with_omniauth(auth)
      user.update_avatar_from_provider!(auth)
    end
    # self.current_user = user
    session[:user_id] = user.id
    session[:customer_id] = nil
    Customer.remove_temporary_current_customer
    flash[:notice] = "Signed in!"
    redirect_back_or_default(root_url)
  end
  
  def create_anonymous
    user = AnonymousUser.create_random
    session[:user_id] = user.id
    # flash[:notice] = "Signed in!"
    redirect_back_or_default(root_url)
  end

  def destroy
    keep_customer = Customer.current_customer rescue nil
    session[:user_id] = nil
    cookies.delete :auth_token
    reset_session
    redirect_to login_url(:customer_id => keep_customer.try(:id)), :notice => "Signed out!"
  end
  
  def map_login
    session[:user_id] = nil
    cookies.delete :auth_token
    reset_session
    
    @mentor = Mentor.find params[:person_id]
    if @mentor.has_valid_login_token? && @mentor.login_token == params[:token]
      redirect_to map_to_person_url(@mentor, @mentor.login_token)
    else
      flash[:error] = "Sorry, but that login token is invalid. Please talk to your program administrator."
      redirect_to login_url
    end
  end

  def map_to_person
    @mentor = Mentor.find params[:person_id]
    if @mentor.has_valid_login_token? && @mentor.login_token == params[:token]
      if @current_user.update_attribute(:person_id, @mentor.id)
        @mentor.invalidate_login_token!
        flash[:notice] = "Your user account has been successfully linked to #{ActionController::Base.helpers.sanitize(@mentor.fullname)}."
        redirect_to root_url
      else
        render_error "Your user account could not be linked successfully."
      end
    else
      render_error "Invalid login token."
    end
  end


  protected  
  
  def fetch_customer
    # logger.info { "Customer Fetch: session => #{session[:customer_id].inspect}, params => #{params[:customer_id].inspect}" }
    @customer = Customer.find(session[:customer_id]) if session[:customer_id]
    @customer = Customer.find(params[:customer_id]) if params[:customer_id]
    if @customer
      cookies.delete :auth_token
      reset_session
      Customer.current_customer = @customer
      session[:customer_id] = @customer.id
      session[:user_id] = nil
    end
  end

  # def password_authentication(login, password)
  #   self.current_user = User.authenticate(login, password)
  #   if logged_in?
  #     successful_login
  #   else
  #     failed_login
  #   end
  # end
  #   
  # def failed_login(message = "Authentication failed.")
  #   flash.now[:error] = message
  #   render :action => 'new'
  # end
  # 
  # def successful_login
  #   if params[:remember_me] == "1"
  #     self.current_user.remember_me
  #     cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
  #   end
  #   session[:limit_login_to] = nil
  #   redirect_back_or_default(root_url)
  #   flash[:notice] = "Logged in successfully"
  # end
end