class UsersController < ApplicationController
  skip_before_filter :check_authorization, only: [:profile, :update_profile, :choose_identity, :update_identity]
  before_filter :apply_extra_styles_if_requested
  before_filter :apply_extra_footer_content_if_requested

  def index
    @users = User.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @users }
    end
  end

  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @user }
    end
  end

  def profile
    return redirect_to choose_identity_path if @current_user.person.class == Person || @current_user.person.nil?
    @person = @current_user.person
    apply_customer_styles
  end

  def update_profile
    @person = @current_user.person
    @person.validate_ready_to_rsvp = true if session[:profile_validations_required].to_s.include?("ready_to_rsvp")
    @person.validate_name = true
    params[:person].delete(:emergency_contact_attributes) if params[:person][:emergency_contact_attributes].values.reject(&:blank?).empty?
    @person.assign_attributes(params[:person])

    for attribute in %w[firstname lastname email high_school_id]
      @person.send("reset_#{attribute}!") unless @current_user.can_edit?(@person, attribute)
    end

    respond_to do |format|
      if @person.save
        flash[:notice] = "Thanks! We updated your profile."
        format.html {
          redirect_to(session[:return_to_after_profile] || root_path)
          session[:return_to_after_profile] = nil
          session[:apply_extra_styles] = nil
        }
      else
        format.html { render action: "profile" }
      end
    end

  end

  def choose_identity
    apply_customer_styles
  end

  def update_identity
    new_identity = h(params[:identity].to_s)
    return redirect_to choose_identity_path unless %w(Student Volunteer Mentor).include?(new_identity)
    if new_identity == "Mentor"
      @current_user.attach_person_record
      redirect_to profile_path
    else
      if @current_user.person.nil?
        @current_user.person = new_identity.constantize.create
        @current_user.save
      end
      redirect_to @current_user.person.update_attribute(:type, new_identity) ? profile_path : choose_identity_path
    end
  end

  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @user }
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        flash[:notice] = "User was successfully created."
        format.html { redirect_to(@user) }
        format.xml  { render xml: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @user = User.find(params[:id])
    new_admin_value = params[:user][:admin]
    @user.admin = new_admin_value if @current_user && @current_user.admin?

    respond_to do |format|
      if @user.save
        flash[:notice] = "User was successfully updated."
        format.html { redirect_to(user_path(@user)) }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def auto_complete_for_user_login
    @users = User.joins(:person).where(["login LIKE :login
                                              OR people.firstname LIKE :fullname
                                              OR people.lastname LIKE :fullname
                                              OR people.display_name LIKE :fullname
                                              OR people.uw_net_id LIKE :fullname",
                                          {login: "%#{params[:user][:login].downcase}%",
                                          fullname: "%#{params[:user][:login].downcase}%"}])
    respond_to do |format|
      format.js
    end
  end

  def admin
    @users = User.paginate conditions: { admin: true }, page: params[:page], per_page: 100

    respond_to do |format|
      format.html { render action: 'index' }
      format.xml  { render xml: @users }
    end

  end

  protected

  def check_authorization
    unless @current_user && @current_user.admin?
      render_error("You are not allowed to access that page.")
    end
  end

end
