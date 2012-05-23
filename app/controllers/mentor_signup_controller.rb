class MentorSignupController < ApplicationController
  before_filter :fetch_mentor
  before_filter :fetch_quarter, :check_if_signups_allowed, :except => ['basics', 'background_check_form', 'risk_form']
  skip_before_filter :check_authorization, :check_if_enrolled

  def index
    @mentor_quarters = @mentor.mentor_quarters.for_quarter(@quarter.id)
    @mentor_quarter_groups = @quarter.mentor_quarter_groups
    @max_quarter_cap = @mentor_quarter_groups.collect(&:capacity).numeric_items.max
    @max_quarter_size = @mentor_quarter_groups.collect(&:mentor_quarters_count).numeric_items.max
    if params[:display] == 'schedule'
      @body_class = 'full'
      render :action => 'schedule'
    end
  end

  def basics
  end
  
  def schedule
  end
  
  def background_check_form
    if request.put?
      @mentor.validate_background_check_form = true
      params[:mentor][:background_check_authorized_at] = params[:mentor][:background_check_authorized_at]=="1" ? Time.now : nil
      if @mentor.update_attributes(params[:mentor])
        flash[:notice] = "Your background check form was successfully received. Thank you."
        redirect_to root_url
      end
    end
  end

  def risk_form
    if request.put?
      @mentor.validate_risk_form = true
      @mentor.risk_form_signature = params[:mentor][:risk_form_signature]
      @mentor.risk_form_signed_at = params[:mentor][:risk_form_signed_at] == "1" ? Time.now : nil
      if @mentor.save
        flash[:notice] = "Your acknowledgment of risk form was successfully received. Thank you."
        redirect_to root_url
      end
    end
  end

  
  def volunteer
    @mentor_quarter_group = @quarter.mentor_quarter_groups.find(params[:id])
    if @mentor_quarter_group.full?
      flash[:error] = "Sorry, but that group is full. Can you find another group that works in your schedule?"
      return redirect_to :back
    end
    m = @mentor_quarter_group.mentor_quarters.create(:mentor_id => @mentor.try(:id), :volunteer => true)
    unless m.valid?
      m = @mentor_quarter_group.deleted_mentor_quarters.find_by_mentor_id(@mentor.id)
      m.update_attributes({:deleted_at => nil, :volunteer => true})
      MentorQuarterGroup.increment_counter(:mentor_quarters_count, @mentor_quarter_group.id) if m.valid?
      # m.add_to_group if m.valid?
    end
    if m.valid?
      flash[:notice] = "You were successfully added to the group."
    else
      flash[:error] = "Could not add you to the group, or you're already in that group."
    end
    
    respond_to do |format|
      format.html { redirect_to root_url }
      format.js   { 
        @mentor_quarter_groups = @quarter.mentor_quarter_groups 
        @mentor_quarters = @mentor.mentor_quarters.for_quarter(@quarter.id)
      }
    end
  end
  
  def drop
    @mentor_quarter = @mentor.mentor_quarters.find(params[:id])
    @mentor_quarter.destroy
    
    flash[:notice] = "Successfully removed you from the group."
    
    respond_to do |format|
      format.html { redirect_to mentor_signup_quarter_url(@quarter) }
      format.js   { 
        @mentor_quarter_group = @mentor_quarter.mentor_quarter_group
        @mentor_quarter_groups = @quarter.mentor_quarter_groups
        @mentor_quarters = @mentor.mentor_quarters.for_quarter(@quarter.id)
      }
    end
  end
  
  def add_my_courses
    @courses = @mentor.student_person_resource
    
    
    respond_to do |format|
      format.js
    end
  end

  protected
  
  def fetch_mentor
    @mentor = @current_user.person
  end
  
  def fetch_quarter
    @quarter = params[:quarter_id].blank? ? Quarter.current_quarter : Quarter.find(params[:quarter_id])
    @quarter ||= Quarter.allowing_signups.try(:first) || Quarter.last
  end
  
  def check_if_signups_allowed
    unless @quarter.allow_signups?
      # Check if the next quarter allows signups unless we've explicitly asked for a specific quarter.
      if @quarter.next.allow_signups? && params[:quarter_id].blank?
        @quarter = @quarter.next
      else
        flash[:error] = "Sorry, but you can't sign up for #{@quarter.title} right now."
        return redirect_to :back rescue redirect_to root_path
      end
    end
  end

end
