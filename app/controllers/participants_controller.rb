class ParticipantsController < ApplicationController
  protect_from_forgery :only => [:create, :update, :destroy, :bulk] 
  skip_before_filter :login_required, :only => [:college_mapper_callback]
  skip_before_filter :check_if_enrolled, :only => [:college_mapper_callback]
  skip_before_filter :check_authorization, :except => [:index, :cohort, :destroy, :bulk]
  
  before_filter :set_report_type

  # GET /participants
  # GET /participants.xml
  def index
    return redirect_to Participant.find(params[:id]) if params[:id]
    @participants = Participant.paginate(:all, :page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @participants }
      format.js { render 'index'}
      format.xls { 
        @participants = Participant.all
        render :action => 'index', :layout => 'basic' 
      }
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
      format.js { render 'index'}
      format.xls { render :action => 'index', :layout => 'basic' } # index.xls.erb
    end
  end

  def cohort
    @grad_year = params[:id]
    @participants = Participant.in_cohort(params[:id])
    
    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml  { render :xml => @participants }
      format.js { render 'index'}
      format.xls { render :action => 'index', :layout => 'basic' } # index.xls.erb
    end
  end

  def high_school_cohort
    return redirect_to(high_school_cohort_path(:high_school_id => params[:high_school_id], :year => params[:cohort])) if params[:cohort]
    @grad_year = params[:year]
    @high_school = HighSchool.find(params[:high_school_id])
    
    unless @current_user && @current_user.can_view?(@high_school)
      return render_error("You are not allowed to view that high school.")
    end
    
    @participants = Participant.in_cohort(@grad_year).in_high_school(@high_school.try(:id))
    @participant_groups = ParticipantGroup.find(:all, :conditions => { :location_id => @high_school, :grad_year => @grad_year })

    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml  { render :xml => @participants }
      format.js { render 'index'}
      format.xls { render :action => 'index', :layout => 'basic' } # index.xls.erb
    end    
  end

  def college
    @college = Institution.find(params[:college_id].to_i)
    @participants = Participant.attending_college(@college.try(:id))
    
    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml  { render :xml => @participants }
      format.js { render 'index'}
      format.xls { render :action => 'index', :layout => 'basic' } # index.xls.erb
    end
  end

  def college_cohort
    @college = Institution.find(params[:college_id].to_i)
    @grad_year = params[:year]
    @participants = Participant.in_cohort(@grad_year).attending_college(@college.try(:id))
    
    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml  { render :xml => @participants }
      format.js { render 'index'}
      format.xls { render :action => 'index', :layout => 'basic' } # index.xls.erb
    end
  end

  def mentor
    @mentor = Mentor.find(params[:mentor_id] == "me" ? User.current_user.try(:person_id) : params[:mentor_id])
    @participants = Participant.assigned_to_mentor(@mentor.try(:id))
    
    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml  { render :xml => @participants }
      format.js { render 'index'}
      format.xls { render :action => 'index', :layout => 'basic' } # index.xls.erb
    end
  end
  
  def group
    @participant_group = ParticipantGroup.find(params[:id])
    @grad_year = @participant_group.grad_year
    @high_school = @participant_group.location

    unless @current_user && @current_user.can_view?(@high_school)
      return render_error("You are not allowed to view that participant group.")
    end
    
    @participants = @participant_group.participants
    @participant_groups = ParticipantGroup.find(:all, :conditions => { :location_id => @high_school, :grad_year => @grad_year })
    
    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml  { render :xml => @participants }
      format.js { render 'index'}
      format.xls { render :action => 'index', :layout => 'basic' } # index.xls.erb
    end    
  end
  
  def add_to_group
    @participant_group = ParticipantGroup.find(params[:participant_group_id])
    @participant = Participant.find(params[:id].split("_")[1])
    @participant_groups = ParticipantGroup.find(:all, :conditions => { :location_id => @participant_group.location_id, :grad_year => @participant_group.grad_year })
    @participant.update_attribute(:participant_group_id, @participant_group.id)
    ParticipantGroup.update_counters @participant_group.id, :participants_count => @participant_group.participants.length    
    
    respond_to do |format|
      format.js
    end
  end

  # GET /participants/1
  # GET /participants/1.xml
  def show
    @participant = Participant.find(params[:id]) rescue Student.find(params[:id])
    @high_school = @participant.high_school
    @grad_year = @participant.grad_year
		@term = Term.current_term
    
    unless @current_user && @current_user.can_view?(@participant)
      return render_error("You are not allowed to view that participant.")
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @participant }
    end
  end

  # GET /participants/new
  # GET /participants/new.xml
  def new
    @participant = Participant.new(:high_school_id => params[:high_school_id])
    @participant.intake_survey_date = Time.now  # only default to setting this field if we're manually creating a new record.
    @participant_groups = []

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @participant }
    end
  end

  # GET /participants/1/edit
  def edit
    @participant = Participant.find(params[:id])
    @participant_groups = ParticipantGroup.find(:all, :conditions => { 
        :location_id => @participant.high_school_id, 
        :grad_year => @participant.grad_year
      })

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
  
  def fetch_participant_group_options
    # @participant = Participant.find(params[:id])
    @participant_groups = ParticipantGroup.find(:all, :conditions => { 
        :location_id => params[:participant][:high_school_id], 
        :grad_year => params[:participant][:grad_year] 
      })
      
    respond_to do |format|
      format.js
    end
  end
	
	def bulk
		render_error("Invalid task request", "Bad request", 400) unless %w[send_email].include?(params[:task])
		@participants = Participant.find(params[:selected]["Participant"].keys)
		
		if params[:task] == "send_email"
			@emails = @participants.collect(&:email).flatten.compact.uniq
			if @emails.empty?
				flash[:error] = "You must select at least one record with an e-mail address."
				render :text => flash[:error], :status => 200
			else
				# flash[:notice] = "Sent #{@template.pluralize(@emails.count, "e-mail address")} to your e-mail program."
				render :js => "window.location.href = 'mailto:#{@emails.join(",")}';"
			end			
		end
	end
  
  def auto_complete_for_participant_fullname
    conditions = ["(LOWER(firstname) LIKE :fullname OR LOWER(lastname) LIKE :fullname)"]
    conditions << "high_school_id = :high_school_id" if params[:high_school_id]
    conditions << "grad_year = :grad_year" if params[:grad_year]
    
    @participants = Participant.find(:all, 
                                      :conditions => [conditions.join(" AND "), 
                                                      {:fullname => "%#{params[:participant][:fullname].downcase}%",
                                                      :grad_year => params[:grad_year],
                                                      :high_school_id => params[:high_school_id]
                                                      }])
    respond_to do |format|
      format.js { 
        render :partial => "shared/auto_complete_person_fullname", 
                :object => @participants, 
                :locals => { :highlight_phrase => params[:participant][:fullname] }
       }
    end
  end
  
  def college_mapper_login
    @participant = Participant.find(params[:id])
    render_error("You must be logged in as a Mentor to do that.") unless @current_user.try(:person).is_a?(Mentor)
    @forbidden = !@participant.mentors.include?(@current_user.try(:person))
    if @forbidden
      message = "You must be linked to that student before you can view his/her CollegeMapper record."
      flash[:error] = message
      return render_error(message)
    end
    @login_token = @current_user.person.try(:college_mapper_counselor).try(:login_token, @participant.college_mapper_id)
    render_error("Could not fetch login token") unless @login_token
    
    respond_to do |format|
      format.js
    end
  end
  
  def college_mapper_callback
    @participant = Participant.find_by_college_mapper_id(params[:user_id])
    @participant.update_college_list_from_college_mapper if params[:update] == 'colleges'
    render :text => "OK\r\n", :status => 200
  rescue
    render :text => "Error\r\n", :status => 500
  end

  protected

  # Stores the value from +params[:report]+ and stores it in +@report+ for use in views.
  def set_report_type
    @report = params[:report] || "basics"
  end
    
end
