class ObjectFiltersController < ApplicationController
  
  def index
    @object_filters = ObjectFilter.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @object_filters }
    end
  end

  def show
    @cohort = params[:cohort] || Participant.current_cohort
    @object_filter = ObjectFilter.find(params[:id])
    @participants = Participant.in_cohort(@cohort)
    @high_schools = HighSchool.partners

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @object_filter }
    end
  end

  def new
    @object_filter = ObjectFilter.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @object_filter }
    end
  end

  def edit
    @object_filter = ObjectFilter.find(params[:id])
  end

  def create
    @object_filter = ObjectFilter.new(params[:object_filter])

    respond_to do |format|
      if @object_filter.save
        flash[:notice] = "ObjectFilter was successfully created."
        format.html { redirect_to(object_filters_url) }
        format.xml  { render :xml => @object_filter, :status => :created, :location => @object_filter }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @object_filter.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @object_filter = ObjectFilter.find(params[:id])

    respond_to do |format|
      if @object_filter.update_attributes(params[:object_filter])
        flash[:notice] = "ObjectFilter was successfully updated."
        format.html { redirect_to(object_filters_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @object_filter.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @object_filter = ObjectFilter.find(params[:id])
    @object_filter.destroy

    respond_to do |format|
      format.html { redirect_to(object_filters_url) }
      format.xml  { head :ok }
    end
  end

  def formatted_criteria
    @object_filter = ObjectFilter.find(params[:id])
    code = @object_filter.criteria
    request = Net::HTTP.post_form(URI.parse('http://pygments.appspot.com/'), {'lang' => 'ruby', 'code' => code})

    respond_to do |format|
      format.js { render :text => request.body }
    end
  end

  protected 
  
  def check_authorization
    unless @current_user && @current_user.admin?
      render_error("You are not allowed to access that page.")
    end
  end

  
end
