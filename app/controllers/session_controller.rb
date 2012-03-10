# This controller handles the login/logout function of the site.  
class SessionController < ApplicationController
  skip_before_filter :login_required, :check_authorization, :check_for_limited_login, :check_if_enrolled

  # before_filter :adjust_format_for_iphone, :only => [:new]

  # render new.rhtml
  def new
  end

  def create
    if params[:uwnetid_button]
      uwnetid_authentication
      return
    end
    # if using_open_id?
    #   open_id_authentication(params[:openid_url])
    # else
    password_authentication(params[:login], params[:password])
    # end
  end
  
  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    # if self.current_user.is_a? PubcookieUser
    #   return_to = request.env['HTTP_REFERER'].to_s unless request.env['HTTP_REFERER'].to_s.blank?
    #   redirect_to ("/expologout/?return_to=" + return_to) and return false
    # end
    redirect_back_or_default('/')
  end

  # def forgot
  #   if params[:commit]
  #     user = User.find_by_login params[:login], :conditions => 'type IS NULL'
  #     flash[:error] = "That username does not exist." and return if user.nil?
  #     user.create_token
  #     if email = UserMailer.deliver_password_reminder(user)
  #       EmailContact.log(user.person, email)
  #       flash[:notice] = "Instructions have been sent to your email address that will tell you how to reset your password."
  #     end
  #   end
  # end
  # 
  # def reset_password
  #   @user = Token.find_object(params[:user_id], params[:token], false)
  #   if @user.nil?
  #     flash[:error] = "That password reset link is invalid. Please try again."
  #     redirect_to :action => "forgot" and return
  #   end
  #   if request.post? && params[:user]
  #     @user.allow_invalid_person = true
  #     if @user.update_attributes(params[:user])
  #       flash[:notice] = "Your password was successfully reset."
  #       @user.create_token
  #       self.current_user = User.authenticate(@user.login, @user.password)
  #       @user.allow_invalid_person = false
  #       redirect_to profile_url and return unless @user.valid? && @user.person.valid?
  #       redirect_to root_url and return
  #     end
  #   end
  # end

  protected  

  # def uwnetid_authentication
  #   return_to = session[:return_to] || request.env['HTTP_REFERER'].to_s || ""
  #   redirect_to ("/expologin/?return_to=" + return_to) and return false
  # end
  # 
  # def open_id_authentication(openid_url)
  #   authenticate_with_open_id(openid_url, :required => [:nickname, :firstname, :lastname, :email]) do |result, identity_url, registration|
  #     if result.successful?
  #       @user = OpenidUser.find_or_initialize_by_identity_url(identity_url)
  #       if @user.new_record?
  #         @user.login = (registration['nickname'] || identity_url)
  #         @user.email = registration['email']
  #         @user.person = Person.new(:firstname => registration['firstname'], :lastname => registration['lastname'])
  #         @user.save(false) 
  #       end
  #       self.current_user = @user
  #       successful_login
  #     else
  #       failed_login result.message
  #     end
  #   end
  # end

  def password_authentication(login, password)
    self.current_user = User.authenticate(login, password)
    if logged_in?
      successful_login
    else
      failed_login
    end
  end
    
  def failed_login(message = "Authentication failed.")
    flash.now[:error] = message
    render :action => 'new'
  end

  def successful_login
    if params[:remember_me] == "1"
      self.current_user.remember_me
      cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
    end
    session[:limit_login_to] = nil
    redirect_back_or_default(root_url)
    flash[:notice] = "Logged in successfully"
    # LoginHistory.login(self.current_user, (request.env["HTTP_X_FORWARDED_FOR"] || request.env["REMOTE_ADDR"]), request.session_options[:id])    
  end
end