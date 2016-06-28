class EventTypesController < ApplicationController
  def index
    @event_types = EventType.find :all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @event_types }
    end
  end

  def show
    @event_type = EventType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @event_type }
    end
  end

  def new
    @event_type = EventType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @event_type }
    end
  end

  def edit
    @event_type = EventType.find(params[:id])
  end

  def create
    @event_type = EventType.new(params[:event_type])

    respond_to do |format|
      if @event_type.save
        flash[:notice] = "EventType was successfully created."
        format.html { redirect_to(@event_type) }
        format.xml  { render xml: @event_type, status: :created, location: @event_type }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @event_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @event_type = EventType.find(params[:id])

    respond_to do |format|
      if @event_type.update_attributes(params[:event_type])
        flash[:notice] = "EventType was successfully updated."
        format.html { redirect_to(@event_type) }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @event_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @event_type = EventType.find(params[:id])
    @event_type.destroy

    respond_to do |format|
      format.html { redirect_to(admin_event_types_url) }
      format.xml  { head :ok }
    end
  end
end