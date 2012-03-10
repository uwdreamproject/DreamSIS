class EventGroupsController < ApplicationController
  def index
    @event_groups = EventGroup.paginate :all, :page => params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @event_groups }
    end
  end

  def show
    @event_group = EventGroup.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event_group }
    end
  end

  def new
    @event_group = EventGroup.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event_group }
    end
  end

  def edit
    @event_group = EventGroup.find(params[:id])
  end

  def create
    @event_group = EventGroup.new(params[:event_group])

    respond_to do |format|
      if @event_group.save
        flash[:notice] = "EventGroup was successfully created."
        format.html { redirect_to(@event_group) }
        format.xml  { render :xml => @event_group, :status => :created, :location => @event_group }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event_group.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @event_group = EventGroup.find(params[:id])

    respond_to do |format|
      if @event_group.update_attributes(params[:event_group])
        flash[:notice] = "EventGroup was successfully updated."
        format.html { redirect_to(@event_group) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event_group.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @event_group = EventGroup.find(params[:id])
    @event_group.destroy

    respond_to do |format|
      format.html { redirect_to(admin_event_group_url) }
      format.xml  { head :ok }
    end
  end
end