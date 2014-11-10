class ScholarshipApplicationsController < ParticipantsController
  before_filter :fetch_participant, :except => :auto_complete_for_scholarship_application_title
  skip_before_filter :check_authorization
  
  # GET /participant_colleges
  # GET /participant_colleges.xml
  def index
    @scholarship_applications = @participant.scholarship_applications.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @scholarship_applications }
    end
  end

  # GET /participant_colleges/1
  # GET /participant_colleges/1.xml
  def show
    @scholarship_application = @participant.scholarship_applications.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @scholarship_application }
    end
  end

  # GET /participant_colleges/new
  # GET /participant_colleges/new.xml
  def new
    @scholarship_application = @participant.scholarship_applications.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @scholarship_application }
    end
  end

  # GET /participant_colleges/1/edit
  def edit
    @scholarship_application = @participant.scholarship_applications.find(params[:id])
  end

  # POST /participant_colleges
  # POST /participant_colleges.xml
  def create
    @scholarship_application = @participant.scholarship_applications.new(params[:scholarship_application])

    respond_to do |format|
      if @scholarship_application.save
        flash[:notice] = 'Scholarship application was successfully created.'
        format.html { redirect_to(participant_path(@participant, :anchor => "scholarship_applications")) }
        format.xml  { render :xml => @scholarship_application, :status => :created, :location => @participant }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @scholarship_application.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /participant_colleges/1
  # PUT /participant_colleges/1.xml
  def update
    @scholarship_application = @participant.scholarship_applications.find(params[:id])

    respond_to do |format|
      if @scholarship_application.update_attributes(params[:scholarship_application])
        flash[:notice] = 'Scholarship application was successfully updated.'
        format.html { redirect_to(participant_path(@participant, :anchor => "scholarship_applications")) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @scholarship_application.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /participant_colleges/1
  # DELETE /participant_colleges/1.xml
  def destroy
    @scholarship_application = @participant.scholarship_applications.find(params[:id])
    @scholarship_application.destroy

    respond_to do |format|
      format.html { redirect_to(participant_scholarship_applications_url) }
      format.xml  { head :ok }
    end
  end

  def auto_complete_for_scholarship_application_title
    @scholarships = Scholarship.find(:all, 
                      :conditions => ["LOWER(title) LIKE ?", '%' + params[:scholarship_application][:title].downcase + '%'],
                      :limit => 10)
    render :json => @scholarships.map { |result| 
      {
        :id => result.id, 
        :value => result.name,
        :klass => result.class.to_s.underscore, 
        :fullname => result.name, 
        :secondary => result.email,
        :tertiary => (Customer.current_customer.customer_label(result.class.to_s.underscore, :titleize => true) || result.class.to_s).titleize
      }
    }
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
