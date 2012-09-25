class RsvpController < ApplicationController
  skip_before_filter :check_authorization, :check_if_enrolled
  skip_before_filter :login_required, :except => [:event_type]
  
  def event
    @event = Event.find(params[:id])
    login_required unless @event.event_group && @event.event_group.open_to_public?
    check_if_external_users_allowed(@event)
    @hide_description_link = true
    @event_attendance = @current_user.person.event_attendances.find_or_initialize_by_event_id(@event.id) if @current_user
  end
  
  def event_group
    @event_group = EventGroup.find(params[:id])
    login_required unless @event_group.open_to_public?
    check_if_external_users_allowed(@event_group)
  end
  
  def event_type
    @event_type = EventType.find(params[:id])
    check_if_external_users_allowed(@event_type)
  end
  
  def rsvp
    @event = Event.find(params[:id])
    check_if_external_users_allowed(@event)
    if !@current_user || !@current_user.person.ready_to_rsvp?(@event)
      session[:return_to_after_rsvp] = request.env["HTTP_REFERER"]
      session[:return_to_after_profile] = request.request_uri
      session[:profile_validations_required] = "ready_to_rsvp"
      flash[:notice] = "Before you can RSVP for events, please login and complete your profile."
      respond_to do |format|
        format.html { return redirect_to(profile_path) }
        format.js   { return render(:js => "window.location.href = '#{profile_path}'") }
      end
    end
    @event_attendance = @current_user.person.event_attendances.find_or_initialize_by_event_id(@event.id)
    @event_attendance.event_shift_id = params[:event_attendance].try(:[], :event_shift_id)
    if request.put? || (request.get? && (params[:rsvp] == true || params[:rsvp] == "true"))
      @event_attendance.rsvp = true
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
        flash[:error] = "We couldn't save your RSVP. Please complete the required information."
        format.html { redirect_to(event_rsvp_path(@event)) }
        format.js
      end
    end
    
  end
  
  private
  
  def check_if_external_users_allowed(event_or_group)
    return true if @current_user && !@current_user.external?
    @event_group = event_or_group.respond_to?(:event_group) ? event_or_group.event_group : event_or_group
    return render_error("External users are not allowed to access that event.") if (@event_group.nil? || !@event_group.open_to_public?)
  end
  
end