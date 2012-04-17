class EventsController < ApplicationController
  skip_before_filter :check_authorization, :only => :show
  before_filter :redirect_to_rsvp_if_not_admin, :only => :show

  # GET /events
  # GET /events.xml
  def index
    @events = Event.paginate(:all, :order => "date desc", :page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @events }
    end
  end

  # GET /events/1
  # GET /events/1.xml
  def show
    @event = Event.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/new
  # GET /events/new.xml
  def new
    @event = Event.new(params[:event])

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
  end

  # POST /events
  # POST /events.xml
  def create
    @event = Event.new(params[:event] || params[:visit])

    respond_to do |format|
      if @event.save
        flash[:notice] = 'Event was successfully created.'
        format.html { redirect_to(event_url(@event)) }
        format.xml  { render :xml => @event, :status => :created, :location => event_url(@event) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.xml
  def update
    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event] || params[:visit])
        flash[:notice] = 'Event was successfully updated.'
        format.html { redirect_to(event_url(@event)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.xml
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(events_url) }
      format.xml  { head :ok }
    end
  end

  protected

  def redirect_to_rsvp_if_not_admin
    @event = Event.find params[:id]
    unless @current_user && (@current_user.admin? || @current_user.person.current_lead?)
      if @event.allow_rsvps?
        redirect_to event_rsvp_url(@event)
      else
        render_error("You are not allowed to access that page.")
      end
    end
  end


end
