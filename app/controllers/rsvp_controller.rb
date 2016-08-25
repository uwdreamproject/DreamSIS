class RsvpController < ApplicationController
  skip_before_filter :check_authorization, :check_if_enrolled
  skip_before_filter :login_required, except: [:event_type, :mentor_available]
  before_filter :load_audience
  
  def event
    @event = Event.find(params[:id])
    login_required unless @event.event_group && @event.event_group.open_to_public?
    check_if_external_users_allowed(@event)
    apply_extra_stylesheet(@event)
    apply_extra_footer_content(@event)
    @hide_description_link = true
    @event_attendance = @current_user.person.event_attendances.find_or_initialize_by_event_id(@event.id) if @current_user
		@share_links = true
		@title = @event.name
  end
  
  def event_group
    @event_group = EventGroup.find(params[:id])
    login_required unless @event_group.open_to_public?
    check_if_external_users_allowed(@event_group)
    apply_extra_stylesheet(@event_group)
    apply_extra_footer_content(@event_group)
		@title = @event_group
  end
  
  def event_group_locations
    @event_group = EventGroup.find(params[:id])
    login_required unless @event_group.open_to_public?
    check_if_external_users_allowed(@event_group)
    apply_extra_stylesheet(@event_group)
    apply_extra_footer_content(@event_group)
		@title = "Locations", @event_group
    
    @counties = {}
    for event in @event_group.future_events(@current_user.try(:person) || @audience)
			county_name = event.location.try(:county).try{ |c| c.gsub("County", "").strip }
      @counties[county_name] ||= {}
      @counties[county_name][event.location] ||= []
      @counties[county_name][event.location] << event
    end
    @counties = @counties.sort_by{ |k,v| k.nil? ? "ZZZZZ" : k.to_s }
  end
  
  def event_type
    @event_type = EventType.find(params[:id])
    check_if_external_users_allowed(@event_type)
  end

  def mentor_available
    @event_groups = EventGroup.find_all_by_open_to_mentors(true)
    @title = "Upcoming Events"
  end

  def rsvp
    @event = Event.find(params[:id])
    check_if_external_users_allowed(@event)
    apply_extra_stylesheet(@event)
    apply_extra_footer_content(@event)
		@title = "RSVP", @event
    
    if !@current_user || !@current_user.person.ready_to_rsvp?(@event)
      session[:return_to_after_rsvp] = request.env["HTTP_REFERER"]
      session[:return_to_after_profile] = request.original_url
      unless request.get?
        session[:return_to_after_profile] << '?' + params.except(:format).to_query
        if request.put?
          session[:return_to_after_profile] << '&rsvp=true'
        end
      end
      session[:profile_validations_required] = "ready_to_rsvp"
      flash[:notice] = "Before you can RSVP for events, please login and complete your profile."
      respond_to do |format|
        format.html { return redirect_to(profile_path(apply_extra_styles: true, apply_extra_footer_content: true)) }
        format.js   {
          session[:return_to_after_profile].sub!(/.js(\Z|\?|\#)/, '\1')
          return render(js: "window.location.href = '#{profile_path(apply_extra_styles: true, apply_extra_footer_content: true)}'")
        }
      end
    end
    @event_attendance = @current_user.person.event_attendances.find_or_initialize_by_event_id(@event.id)
    @event_attendance.event_shift_id = params[:event_attendance].try(:[], :event_shift_id)
    @event_attendance.audience = params[:event_attendance].try(:[], :audience) || @event_attendance.person.class.to_s
    if request.put? || (request.get? && (params[:rsvp] == true || params[:rsvp] == "true"))
      @event_attendance.rsvp = true
      @event_attendance.enforce_rsvp_limits = true
    elsif request.delete?
      @event_attendance.rsvp = false
    end
    
    respond_to do |format|
      if @event_attendance.save
        if @event_attendance.rsvp?
          flash[:notice] = "Thanks for signing up."
          format.html { redirect_to(session[:return_to_after_rsvp] || event_rsvp_path(@event)) && session[:return_to_after_rsvp] = nil }
          format.js
        elsif !@event_attendance.rsvp?
          flash[:info] = "Cancellation received. Sorry you can't join us."
          format.html { redirect_to(event_rsvp_path(@event)) }
          format.js
        end
      else
        if @event_attendance.errors[:enforce_rsvp_limits] && @event_attendance.errors[:enforce_rsvp_limits].any?
          flash[:error] = "Sorry, but the capacity for that event has been reached."
        elsif @event_attendance.errors[:audience] && @event_attendance.errors[:audience].any?
          flash[:error] = "Invalid Audience, check that you are using the correct RSVP link."
        elsif @event_attendance.errors[:event_shift_id] && @event_attendance.errors[:event_shift_id].any?
          flash[:error] = "You must select a shift/role in order to RSVP. Please select from the list, and
                           then click the button again to submit your RSVP."
        elsif @event_attendance.errors[:base] && @event_attendance.errors[:base].any?
          flash[:error] = @event_attendance.errors[:base].to_sentence
        else
          flash[:error] = "We couldn't save your RSVP. Please complete the required information."
        end
          format.html { redirect_to(event_rsvp_path(@event)) }
          format.js
      end
    end
    
  end
  
  private
  
  def check_if_external_users_allowed(event_or_group)
    return true if @current_user && !@current_user.external?
    @event_group = event_or_group.respond_to?(:event_group) ? event_or_group.event_group : event_or_group
    if (@event_group.nil? || !@event_group.open_to_public?)
      return render_error("External users are not allowed to access that event.")
    else
      session[:external_login_context] = :rsvp
    end
  end
  
  def apply_extra_stylesheet(event_or_group)
    @include_typekit = true
    @event_group = event_or_group.respond_to?(:event_group) ? event_or_group.event_group : event_or_group
    super(@event_group.stylesheet_url) if @event_group && !@event_group.stylesheet_url.blank?
  end

  def apply_extra_footer_content(event_or_group)
    @event_group = event_or_group.respond_to?(:event_group) ? event_or_group.event_group : event_or_group
    super(@event_group.footer_content) if @event_group && !@event_group.footer_content.blank?
  end
  
  def load_audience
    @audience = params[:audience].constantize if %w(Student Participant Mentor Volunteer).include?(params[:audience])
  end
  
end
