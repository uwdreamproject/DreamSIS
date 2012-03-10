class RsvpController < ApplicationController
  skip_before_filter :check_authorization
  
  def event
    @event = Event.find(params[:id])
  end
  
  def event_group
    @event_group = EventGroup.find(params[:id])
  end
  
  def event_type
    @event_type = EventType.find(params[:id])
  end
  
  def rsvp
    @event = Event.find(params[:id])
    @event_attendance = @current_user.person.event_attendances.find_or_create_by_event_id(@event.id)
    if request.put?
      @event_attendance.rsvp = true
    elsif request.delete?
      @event_attendance.rsvp = false
    end
    if @event_attendance.save
      flash[:notice] = "Thanks for signing up."
    end
    
    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
    
  end
end