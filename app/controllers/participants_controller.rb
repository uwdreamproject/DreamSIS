class ParticipantsController < ApplicationController
  protect_from_forgery :only => [:create, :update, :destroy] 
  skip_before_filter :check_authorization, :except => [:index, :cohort, :destroy]

  # GET /participants
  # GET /participants.xml
  def index
    @participants = Participant.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @participants }
      format.xls { render :action => 'index', :layout => 'basic' } # index.xls.erb
    end
  end

  def high_school
    @high_school = HighSchool.find(params[:id])
    
    unless @current_user && @current_user.can_view?(@high_school)
      return render_error("You are not allowed to view that high school.")
    end
    
    @participants = @high_school.participants

    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml  { render :xml => @participants }
      format.xls { render :action => 'index', :layout => 'basic' } # index.xls.erb
    end
  end

  def cohort
    @grad_year = params[:id]
    @participants = Participant.in_cohort(params[:id])
    
    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml  { render :xml => @participants }
      format.xls { render :action => 'index', :layout => 'basic' } # index.xls.erb
    end
  end

  def high_school_cohort
    @grad_year = params[:year]
    @high_school = HighSchool.find(params[:high_school_id])
    
    unless @current_user && @current_user.can_view?(@high_school)
      return render_error("You are not allowed to view that high school.")
    end
    
    @participants = Participant.in_cohort(@grad_year).in_high_school(@high_school.try(:id))

    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml  { render :xml => @participants }
      format.xls { render :action => 'index', :layout => 'basic' } # index.xls.erb
    end    
  end

  # GET /participants/1
  # GET /participants/1.xml
  def show
    @participant = Participant.find(params[:id])
    
    unless @current_user && @current_user.can_view?(@participant)
      return render_error("You are not allowed to view that participant.")
    end
    
    participants = Participant.in_cohort(@participant.grad_year).in_high_school(@participant.high_school_id)
    my_index = participants.index(@participant)
    start_index = my_index - 5
    start_index = 0 if start_index < 0
    end_index = my_index + 5
    end_index = participants.size-1 if end_index > participants.size
    @participants_for_nav = participants[start_index..end_index]    

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @participant }
    end
  end

  # GET /participants/new
  # GET /participants/new.xml
  def new
    @participant = Participant.new
    @participant.intake_survey_date = Time.now  # only default to setting this field if we're manually creating a new record.

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @participant }
    end
  end

  # GET /participants/1/edit
  def edit
    @participant = Participant.find(params[:id])

    unless @current_user && @current_user.can_edit?(@participant)
      return render_error("You are not allowed to edit that participant.")
    end

  end

  # POST /participants
  # POST /participants.xml
  def create
    @participant = Participant.new(params[:participant])

    respond_to do |format|
      if @participant.save
        flash[:notice] = 'Participant was successfully created.'
        format.html { redirect_to(@participant) }
        format.xml  { render :xml => @participant, :status => :created, :location => @participant }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @participant.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /participants/1
  # PUT /participants/1.xml
  def update
    @participant = Participant.find(params[:id])

    unless @current_user && @current_user.can_edit?(@participant)
      return render_error("You are not allowed to edit that participant.")
    end

    @college_application = @participant.college_applications.find(params[:college_application_id]) if params[:college_application_id]

    @participant.override_binder_date = params[:override_binder_date] if params[:override_binder_date]
    @participant.override_fafsa_date = params[:override_fafsa_date] if params[:override_fafsa_date]

    params[:participant][:how_did_you_hear_option_ids] ||= []

    respond_to do |format|
      if @participant.update_attributes(params[:participant])
        flash[:notice] = 'Participant was successfully updated.'
        format.html { redirect_to(@participant) }
        format.xml  { head :ok }
        format.js
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @participant.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end

  # DELETE /participants/1
  # DELETE /participants/1.xml
  def destroy
    @participant = Participant.find(params[:id])
    @participant.destroy

    respond_to do |format|
      format.html { redirect_to(participants_url) }
      format.xml  { head :ok }
    end
  end
  
  def note
    @participant = Participant.find(params[:id])
    @note = @participant.notes.create(params[:note])
    
    respond_to do |format|
      format.html { redirect_to @participant }
      format.js
    end    
  end
  
  # Checks for a duplicate participant based on the parameters passed. Used in an AJAX query on the participant form.
  def check_duplicate
    @duplicates = Participant.possible_duplicates(params[:participant], 10)
    
    respond_to do |format|
      format.js
    end
  end
  
  def auto_complete_for_participant_fullname
    @participants = Participant.find(:all, 
                                      :conditions => ["LOWER(firstname) LIKE :fullname OR LOWER(lastname) LIKE :fullname", 
                                                      {:fullname => "%#{params[:participant][:fullname].downcase}%"}])
    render :inline => "<%= auto_complete_result @participants, 'fullname' %>"
  end

  protected
    
end
