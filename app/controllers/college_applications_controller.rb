class CollegeApplicationsController < ParticipantsController
  before_filter :fetch_participant
  skip_before_filter :check_authorization
  
  # GET /participant_colleges
  # GET /participant_colleges.xml
  def index
    @college_applications = @participant.college_applications.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @college_applications }
    end
  end

  # GET /participant_colleges/1
  # GET /participant_colleges/1.xml
  def show
    @college_application = @participant.college_applications.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @college_application }
    end
  end

  # GET /participant_colleges/new
  # GET /participant_colleges/new.xml
  def new
    @college_application = @participant.college_applications.new
    @college_application_choice_options = Customer.college_application_choice_options_array

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @college_application }
    end
  end

  # GET /participant_colleges/1/edit
  def edit
    @college_application = @participant.college_applications.find(params[:id])
    @college_application_choice_options = [[@college_application.try(:choice)] + Customer.college_application_choice_options_array].flatten.uniq
  end

  # POST /participant_colleges
  # POST /participant_colleges.xml
  def create
    @college_application = @participant.college_applications.new(params[:college_application])

    respond_to do |format|
      if @college_application.save
        flash[:notice] = 'College Application was successfully created.'
        format.html { redirect_to(@participant) }
        format.xml  { render :xml => @college_application, :status => :created, :location => @participant }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @college_application.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /participant_colleges/1
  # PUT /participant_colleges/1.xml
  def update
    @college_application = @participant.college_applications.find(params[:id])

    respond_to do |format|
      if @college_application.update_attributes(params[:college_application])
        flash[:notice] = 'College Application was successfully updated.'
        format.html { redirect_to(@participant) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @college_application.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /participant_colleges/1
  # DELETE /participant_colleges/1.xml
  def destroy
    @college_application = @participant.college_applications.find(params[:id])
    @college_application.destroy

    respond_to do |format|
      format.html { redirect_to(participant_college_applications_url) }
      format.xml  { head :ok }
    end
  end

  def auto_complete_for_institution_name
    @institutions = Institution.find_all_by_name(params[:college_application][:institution_name].to_s.downcase)[0..10]
    render :partial => "shared/auto_complete_institution_name", 
            :object => @institutions, 
            :locals => { :highlight_phrase => params[:college_application][:institution_name].to_s }
  end

  
  protected
  
  def fetch_participant
    @participant = Participant.find(params[:participant_id])
    
    unless @current_user && @current_user.can_view?(@participant)
      flash[:error] = "You are not allowed to edit this participant"
      return redirect_to :back
    end
    
  end
  
end
