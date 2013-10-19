class ActivityLogsController < ApplicationController
	
  def index
    @activity_logs = ActivityLog.paginate :all, :page => params[:page]
  
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @activity_logs }
    end
  end
  
  def show
    @activity_log = ActivityLog.find(params[:id])
  
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @activity_log }
    end
  end
  
  def new
    @activity_log = ActivityLog.new
    @activity_log.customer_id = Customer.current_customer.id
  
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @activity_log }
    end
  end
  
  def edit
    @activity_log = ActivityLog.find(params[:id])
  end
  
  def create
    @activity_log = ActivityLog.new(params[:activity_log])
    @activity_log.customer_id = Customer.current_customer.id
    
    respond_to do |format|
      if @activity_log.save
        flash[:notice] = 'Activity Log was successfully created.'
        format.html { redirect_to(@activity_log) }
        format.xml  { render :xml => @activity_log, :status => :created, :location => @activity_log }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @activity_log.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    @activity_log = ActivityLog.find(params[:id])      

    respond_to do |format|
      if @activity_log.update_attributes(params[:activity_log])
				format.js		{ flash[:saved] = "Saved." }
        format.html { flash[:notice] = 'Activity Log was successfully updated.'; redirect_to(@activity_log) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @activity_log.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @activity_log = ActivityLog.find(params[:id])
    @activity_log.destroy
  
    respond_to do |format|
      format.html { redirect_to(activity_logs_url) }
      format.xml  { head :ok }
    end
  end
	

end