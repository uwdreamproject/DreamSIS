# This controller handles the login/logout function of the site.  
class SessionController < ApplicationController
  skip_before_filter :login_required, :check_authorization, :check_for_limited_login, :check_if_enrolled

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
      attach_person_record = session[:external_login_context].nil? ? true : false
      user = PubcookieUser.authenticate(auth["uid"], nil, nil, attach_person_record)
      return redirect_to login_url, :error => "Could not login. Please try again." unless user
    else
      user = User.find_by_provider_and_uid(auth["provider"], auth["uid"]) || User.create_with_omniauth(auth)
      user.update_avatar_from_provider!(auth)
    end
    # self.current_user = user
    session[:user_id] = user.id
    flash[:notice] = "Signed in!"
    redirect_back_or_default(root_url)
  end

  def destroy
    session[:user_id] = nil
    cookies.delete :auth_token
    reset_session
    redirect_to root_url, :notice => "Signed out!"
  end





  protected  

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