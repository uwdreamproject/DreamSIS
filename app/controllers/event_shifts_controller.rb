class EventShiftsController < ApplicationController
  before_filter :fetch_event
  
  def index
    @event_shift = @event.shifts

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @event_shift }
    end
  end

  def show
    @event_shift = @event.shifts.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @event_shift }
    end
  end

  def new
    @event_shift = @event.shifts.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @event_shift }
    end
  end

  def edit
    @event_shift = @event.shifts.find(params[:id])
  end

  def create
    @event_shift = @event.shifts.new(params[:event_shift])

    respond_to do |format|
      if @event_shift.save
        flash[:notice] = "Shift was successfully created."
        format.html { redirect_to([@event, @event_shift]) }
        format.xml  { render xml: @event_shift, status: :created, location: @event_shift }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @event_shift.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @event_shift = @event.shifts.find(params[:id])

    respond_to do |format|
      if @event_shift.update_attributes(params[:event_shift])
        flash[:notice] = "Shift was successfully updated."
        format.html { redirect_to([@event, @event_shift]) }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @event_shift.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @event_shift = @event.shifts.find(params[:id])
    @event_shift.destroy

    respond_to do |format|
      format.html { redirect_to(event_event_shifts_url(@event)) }
      format.xml  { head :ok }
    end
  end
  
  protected
  
  def fetch_event
    @event = Event.find params[:event_id]
  end
end
