class MentorSignupController < ApplicationController
  before_filter :fetch_mentor
  before_filter :fetch_term, except: ['background_check_form', 'risk_form', 'conduct_form', 'driver_form']
	before_filter :check_if_signups_allowed, except: ['basics', 'background_check_form', 'risk_form', 'conduct_form', 'driver_form']
  skip_before_filter :check_authorization, :check_if_enrolled
  before_filter :apply_customer_styles

  def index
    @mentor_terms = @mentor.mentor_terms.for_term(@term.id) rescue []
    @mentor_term_groups = @term.mentor_term_groups.select {|mtg| !(mtg.none_option == true)}
    @max_term_cap = @mentor_term_groups.collect(&:capacity).numeric_items.max
    @max_term_size = @mentor_term_groups.collect(&:mentor_terms_count).numeric_items.max
    if params[:display] == 'schedule'
      @body_class = 'full'
      render action: 'schedule'
    end
  end

  def basics
  end
  
  def schedule
  end
  
  def background_check_form
    if request.put?
      @mentor.validate_background_check_form = true
      if @mentor.update_attributes(params[:mentor])
        flash[:notice] = "Your background check form was successfully received. Thank you."
        redirect_to root_url
      end
    elsif request.get?
      if !@mentor.passed_background_check? && @mentor.background_check_authorized == true
        @mentor.update_attributes({background_check_authorized: false,
                                   background_check_authorized_at: nil,
                                   background_check_run_at: nil,
                                   background_check_result: nil
                                  })
      end
      if !@mentor.passed_sex_offender_check? && @mentor.background_check_authorized == true
        @mentor.update_attributes({background_check_authorized: false,
                                   background_check_authorized_at: nil,
                                   sex_offender_check_run_at: nil,
                                   sex_offender_check_result: nil
                                  })
      end
    end
  end

  def driver_form
    if request.put?
      if params[:driver]
        if params[:driver][:checkboxes] && params[:driver].count != (params[:driver][:checkboxes].to_i + 1)
          flash[:error] = "You must agree to all statements"
          return redirect_to :back
        end
      end
      @mentor.validate_driver_form = true
      @mentor.driver_form_signature = params[:mentor][:driver_form_signature]
      @mentor.driver_form_signed_at = params[:mentor][:driver_form_signed_at] == "1" ? Time.now : nil
      @mentor.has_previous_driving_convictions = params[:mentor][:has_previous_driving_convictions]
      @mentor.driver_form_offense_response = params[:mentor][:driver_form_offense_response]
      if @mentor.save
        flash[:notice] = "Your conduct agreement form was successfully received. Thank you."
        redirect_to root_url
      end
    end
  end

  def conduct_form
    if request.put?
      if params[:conduct]
        if params[:conduct][:dream_project] && params[:conduct].count != 19
          flash[:error] = "You must agree to all statements"
          return redirect_to :back
        end
      end
      @mentor.validate_conduct_form = true
      @mentor.conduct_form_signature = params[:mentor][:conduct_form_signature]
      @mentor.conduct_form_signed_at = params[:mentor][:conduct_form_signed_at] == "1" ? Time.now : nil
      if @mentor.save
        flash[:notice] = "Your conduct agreement form was successfully received. Thank you."
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
    @mentor_term_group = @term.mentor_term_groups.find(params[:id])
    if @mentor_term_group.full?
      flash[:error] = "Sorry, but that group is full. Can you find another group that works in your schedule?"
      return redirect_to :back
    end
    m = @mentor_term_group.mentor_terms.create(mentor_id: @mentor.try(:id), volunteer: true)
    unless m.valid?
      m = @mentor_term_group.deleted_mentor_terms.find_by_mentor_id(@mentor.id)
      m.update_attributes({deleted_at: nil, volunteer: true})
      MentorTermGroup.increment_counter(:mentor_terms_count, @mentor_term_group.id) if m.valid?
      # m.add_to_group if m.valid?
    end
    if m.valid?
      flash[:notice] = "You were successfully added to the group."
      if Customer.link_to_uw? && !@mentor.correct_sections?
        flash[:notice] << " You are still not signed up for the correct sections."
        return redirect_to :back
      end
    else
      flash[:error] = "Could not add you to the group, or you're already in that group."
    end
    
    respond_to do |format|
      format.html { redirect_to root_url }
      format.js   { 
        @mentor_term_group.reload
        @mentor_term_groups = @term.mentor_term_groups 
        @mentor_terms = @mentor.mentor_terms.for_term(@term.id)
      }
    end
  end
  
  def drop
    @mentor_term = @mentor.mentor_terms.find(params[:id])
    @mentor_term.destroy
    
    flash[:notice] = "Successfully removed you from the group."
    if Customer.link_to_uw? && !@mentor.correct_sections?
      flash[:notice] << " You are still not signed up for the correct sections."
    end
    respond_to do |format|
      format.html { redirect_to mentor_signup_term_url(@term) }
      format.js   { 
        @mentor_term_group = @mentor_term.mentor_term_group
        @mentor_term_group.reload
        @mentor_term_groups = @term.mentor_term_groups
        @mentor_terms = @mentor.mentor_terms.for_term(@term.id)
      }
    end
  end
  
  def add_my_courses
    @course_meetings = @mentor.student_person_resource.course_meetings(@term)
    
    respond_to do |format|
      format.js
    end
  end

  protected
  
  def fetch_mentor
    @mentor = @current_user.person
  end
  
  def fetch_term
    @term = params[:term_id].blank? ? Term.allowing_signups.try(:first) : Term.find(params[:term_id])
    @term ||= Term.current_term || Term.last
  end
  
  def check_if_signups_allowed
    unless @term.allow_signups?
      # Check if the next term allows signups unless we've explicitly asked for a specific term.
      if @term.respond_to?(:next) && @term.next.allow_signups? && params[:term_id].blank?
        @term = @term.next
      else
        flash[:error] = "Sorry, but you can't sign up for #{@term.title} right now."
        return redirect_to :back rescue redirect_to root_path
      end
    end
  end

end
