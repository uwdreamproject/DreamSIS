class LocationsController < ApplicationController
  protect_from_forgery :except => [:auto_complete_for_location_name, :auto_complete_for_institution_name] 
  
  skip_before_filter :check_authorization, :only => [:show]
  
  # GET /locations
  # GET /locations.xml
  def index
    return redirect_to(request.env['REQUEST_URI'].include?("colleges") ? college_path(params[:id]) : location_path(params[:id])) if params[:id]
    @locations = Location.paginate(:all, :page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @locations }
    end
  end

  # GET /locations/1
  # GET /locations/1.xml
  def show
    if request.env['REQUEST_URI'].include?("colleges")
      @location = Institution.find(params[:id].to_i < 100000 ? -params[:id].to_i.abs : params[:id])
    else
      @location = Location.find(params[:id])
    end

    respond_to do |format|
      format.html { render :action => (@location.is_a?(Institution) || @location.is_a?(College) ? 'college' : 'show')}
      format.xml  { render :xml => @location }
    end
  end

  def colleges
    # render college.html.erb
  end
  
  def applications
    @location = Institution.find(params[:id])

    respond_to do |format|
      format.html
    end    
  end

  # GET /locations/new
  # GET /locations/new.xml
  def new
    klass = (params[:type] || "Location").constantize
    klass = Location unless klass.new.is_a?(Location)
    @location = klass.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @location }
    end
  end

  # GET /locations/1/edit
  def edit
    @location = Location.find(params[:id])
  end

  # POST /locations
  # POST /locations.xml
  def create
    klass = (params[:type] || "Location").constantize
    klass = Location unless klass.new.is_a?(Location)
    @location = klass.new(params[:location] || params[:college] || params[:high_school])

    respond_to do |format|
      if @location.save
        flash[:notice] = 'Location was successfully created.'
        format.html { redirect_to(@location) }
        format.xml  { render :xml => @location, :status => :created, :location => @location }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @location.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /locations/1
  # PUT /locations/1.xml
  def update
    @location = Location.find(params[:id])

    respond_to do |format|
      if @location.update_attributes(params[:location] || params[:college] || params[:high_school])
        flash[:notice] = 'Location was successfully updated.'
        format.html { redirect_to(@location) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @location.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /locations/1
  # DELETE /locations/1.xml
  def destroy
    @location = Location.find(params[:id])
    @location.destroy

    respond_to do |format|
      format.html { redirect_to(locations_url) }
      format.xml  { head :ok }
    end
  end

  def auto_complete_for_location_name
    @locations = Location.find(:all, :conditions => ["LOWER(name) LIKE ?", "%#{params[:location][:name].to_s.downcase}%"])
    render :partial => "shared/auto_complete_location_name", 
            :object => @locations, 
            :locals => { :highlight_phrase => params[:location][:name] }
  end

  def auto_complete_for_institution_name
    @institutions = Institution.find_all_by_name(params[:college][:institution_name].to_s.downcase)[0..10]
    render :partial => "shared/auto_complete_institution_name", 
            :object => @institutions, 
            :locals => { :highlight_phrase => params[:college][:institution_name].to_s }
  end


  
  protected 
  
  def check_authorization
    unless @current_user && (@current_user.admin? || @current_user.try(:person).try(:current_lead?))
      render_error("You are not allowed to access that page.")
    end
  end
  
end
