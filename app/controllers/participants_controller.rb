class ParticipantsController < ApplicationController
  protect_from_forgery :only => [:create, :update, :destroy, :bulk] 
  skip_before_filter :login_required, :only => [:college_mapper_callback]
  skip_before_filter :check_if_enrolled, :only => [:college_mapper_callback]
  skip_before_filter :check_authorization, :except => [:index, :cohort, :destroy]
  
	before_filter :set_title_prefix
  before_filter :set_report_type

  # GET /participants
  # GET /participants.xml
  def index
    return redirect_to Participant.find(params[:id]) if params[:id]
    @participants = Participant.page(params[:page])
		@cache_key = fragment_cache_key(:action => :index, :format => :xlsx)
    @export = report_type.for_key(@cache_key)

    respond_to do |format|
      format.html
      format.xml  { render :xml => @participants.unpaginate }
      format.js
      format.xlsx { respond_to_xlsx }
    end
  end

  def high_school
    @high_school = HighSchool.find(params[:id] || params[:high_school_id])
		@title << @high_school
    
    unless @current_user && @current_user.can_view?(@high_school)
      return render_error("You are not allowed to view that high school.")
    end
    
    @participants = @high_school.participants.page(params[:page])
		@cache_key = fragment_cache_key(:action => :high_school, :id => @high_school.id, :format => :xlsx)
    @export = report_type.for_key(@cache_key)

    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml  { render :xml => @participants.unpaginate }
      format.js   { render 'index'}
      format.xlsx { respond_to_xlsx }
    end
  end

  def cohort
    @grad_year = params[:id]
    @participants = Participant.in_cohort(params[:id]).page(params[:page])
		@title << @grad_year
		@cache_key = fragment_cache_key(:action => :cohort, :id => @grad_year, :format => :xlsx)
    @export = report_type.for_key(@cache_key)
    
    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml  { render :xml => @participants.unpaginate }
      format.js   { render 'index'}
		  format.xlsx { respond_to_xlsx }
    end
  end

  def high_school_cohort
    return redirect_to(high_school_cohort_path(:high_school_id => params[:high_school_id], :year => params[:cohort])) if params[:cohort]
    @grad_year = params[:year]
    @high_school = HighSchool.find(params[:high_school_id])
		@title << @high_school
		@title << @grad_year
    
    unless @current_user && @current_user.can_view?(@high_school)
      return render_error("You are not allowed to view that high school.")
    end
    
    @participants = Participant.in_cohort(@grad_year).in_high_school(@high_school.try(:id)).page(params[:page])
    @participant_groups = ParticipantGroup.find(:all, :conditions => { :location_id => @high_school, :grad_year => @grad_year })
		@cache_key = fragment_cache_key(:action => :high_school_cohort, :id => @high_school.id, :cohort => @grad_year, :format => :xlsx)
    @export = report_type.for_key(@cache_key)

    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml  { render :xml => @participants.unpaginate }
      format.js   { render 'index'}
		  format.xlsx { respond_to_xlsx }
    end    
  end

  def college
    @college = Institution.find(params[:college_id].to_i)
    @participants = Participant.where("0=1").page(1)
    @stages = CollegeApplication::Stages
		@title << @college
		@cache_key = fragment_cache_key(:action => :college, :id => @college.try(:id), :format => :xlsx)
    @export = report_type.for_key(@cache_key)

    if request.xhr?
      @participant_ids = @college.interested_participants.select("people.id").collect(&:id)
      @stages = {}
      for stage in CollegeApplication::Stages
        stage_participants = @college.try("#{stage}_participants")
        @stages[stage] = stage_participants.collect(&:id)
        @participant_ids += @stages[stage]
      end
      @participants = Participant.where(id: @participant_ids).page(params[:page])
    end
    
    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml  { render :xml => @participants.unpaginate }
      format.js   { render 'index'}
		  format.xlsx { respond_to_xlsx }
    end
  end

  def college_cohort
    @college = Institution.find(params[:college_id].to_i)
    @grad_year = params[:year]
    @participants = Participant.in_cohort(@grad_year).attending_college(@college.try(:id)).page(params[:page])
		@title << @college
		@title << @grad_year
		@cache_key = fragment_cache_key(:action => :college_cohort, :id => @college.try(:id), :cohort => @grad_year, :format => :xlsx)
    @export = report_type.for_key(@cache_key)
    
    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml  { render :xml => @participants.unpaginate }
      format.js   { render 'index'}
		  format.xlsx { respond_to_xlsx }
    end
  end

  def mentor
    @mentor = Mentor.find(params[:mentor_id] == "me" ? User.current_user.try(:person_id) : params[:mentor_id])
    @participants = Participant.assigned_to_mentor(@mentor.try(:id)).page(params[:page])
		@title << "Assigned to #{@mentor.try(:fullname)}"
		@cache_key = fragment_cache_key(:action => :mentor, :id => @mentor.id, :format => :xlsx)
    @export = report_type.for_key(@cache_key)
		
		respond_to do |format|
      format.html { render :action => 'index' }
      format.xml  { render :xml => @participants.unpaginate }
      format.js   { render 'index'}
		  format.xlsx { respond_to_xlsx }
    end
  end

  def program
    @program = Program.find(params[:program_id])
    @participants = @program.participants.page(params[:page])
		@title << @program.try(:title)
		@cache_key = fragment_cache_key(:action => :program, :id => @program.id, :format => :xlsx)
    @export = report_type.for_key(@cache_key)
    
    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml  { render :xml => @participants.unpaginate }
      format.js   { render 'index'}
		  format.xlsx { respond_to_xlsx }
    end
  end

  
  def group
    @participant_group = ParticipantGroup.find(params[:id])
    @grad_year = @participant_group.grad_year
    @high_school = @participant_group.location

    unless @current_user && @current_user.can_view?(@high_school)
      return render_error("You are not allowed to view that participant group.")
    end
    
    @participants = @participant_group.participants.page(params[:page])
    @participant_groups = ParticipantGroup.find(:all, :conditions => { :location_id => @high_school, :grad_year => @grad_year })
		@cache_key = fragment_cache_key(:action => :group, :id => @participant_group.id, :format => :xlsx)
    @export = report_type.for_key(@cache_key)
    
    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml  { render :xml => @participants.unpaginate }
      format.js   { render 'index'}
		  format.xlsx { respond_to_xlsx }
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
    @event_attendances = @participant.respond_to?(:relevant_event_attendances) ? @participant.relevant_event_attendances : @participant.event_attendances.non_visits
    @grad_year = @participant.grad_year
		@term = Term.current_term
    @title = @participant.try(:fullname, :middlename => false)
    @visits = @high_school.events(@term, nil, true, 100) if @high_school
		
    unless @current_user && @current_user.can_view?(@participant)
      return render_error("You are not allowed to view that participant.")
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @participant }
    end
  end
	
  def avatar
    @participant = Participant.find(params[:id]) rescue Student.find(params[:id])
    unless @current_user && @current_user.can_view?(@participant)
      return render_error("You are not allowed to view that participant.")
    end
    
		if @participant.avatar?
			av = params[:size] ? @participant.avatar.versions[params[:size].to_sym] : @participant.avatar
			return send_default_photo(params[:size]) if av.nil?
      # return send_data(av.read, :disposition => 'inline', :type => 'image/jpeg')
      return redirect_to av.url
    else
      return send_default_photo(params[:size]) if av.nil?
    end
  end
	
  def event_attendances
    @participant = Participant.find(params[:id]) rescue Student.find(params[:id])
    @event_attendances = @participant.event_attendances.joins(:event)
    @event_attendances = @event_attendances.where("events.type = ? OR events.always_show_on_attendance_pages = ?", params[:type], true) if params[:type]
    @event_attendances = @event_attendances.where("events.date IN (?)", params[:dates]) if params[:dates]
    
    respond_to do |format|
      format.json { 
        render :json => @event_attendances.as_json(include: { 
          event: { methods: [:attendance_options, :short_title] }
        }).group_by{|e| e[:event]["date"] }
      }
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
        format.html { redirect_back_or_default(@participant) }
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

  # Checks for a duplicate participant based on the parameters passed. Used in an AJAX query on the participant form.
  def check_duplicate
    @duplicates = Participant.possible_duplicates(params[:participant], 10)
    
    respond_to do |format|
      format.js
    end
  end
  
  # Forces a refresh of the filter cache for this participant.
  def refresh_filter_cache
    @participant = Participant.find(params[:id])
    @participant.update_filter_cache!
    flash[:notice] = "Stats successfully updated." if @participant.save
    
    respond_to do |format|
      format.html { redirect_to :back }
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
	
  def auto_complete_for_participant_fullname
    if params[:term].to_i != 0
      @participants = [ Participant.find(params[:term].to_i) ]
    else      
      conditions = ["(LOWER(firstname) LIKE :fullname OR LOWER(lastname) LIKE :fullname)"]
      conditions << "high_school_id = :high_school_id" if params[:high_school_id]
      conditions << "grad_year = :grad_year" if params[:grad_year]
    
      @participants = Participant.find(:all, 
                                        :conditions => [conditions.join(" AND "), 
                                                        {:fullname => "%#{params[:term].downcase}%",
                                                        :grad_year => params[:grad_year],
                                                        :high_school_id => params[:high_school_id]
                                                        }])
    end
    
    render :json => @participants.map { |result| 
      {
        :id => result.id, 
        :value => h(result.fullname),
        :klass => result.class.to_s.underscore.titleize, 
        :fullname => h(result.fullname),
        :secondary => h(result.email),
        :tertiary => h((Customer.current_customer.customer_label(result.class.to_s.underscore, :titleize => true) || result.class.to_s).titleize)
      }
    }
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

	def check_export_status
		@export = report_type.find(params[:id])
		respond_to do |format|
			format.html { render :text => (@export.try(:status) || "does not exist") }
			format.js
		end
	end

  protected

  # Stores the value from +params[:report]+ and stores it in +@report+ for use in views.
  def set_report_type
    @report = params[:report].blank? ? "basics" : ERB::Util.html_escape(params[:report])
    @report = "basics" unless Participant::ReportTypes.keys.collect(&:to_s).include?(@report)
  end

	def set_title_prefix
		@title = ["Participants"]
	end

  def send_default_photo(size)
		filename = size == "thumb" ? "blank_avatar_thumb.png" : "blank_avatar.png"
    send_file File.join(Rails.root, "public", "images", filename), 
              :disposition => 'inline', :type => 'image/png', :status => 203
  end  

	def respond_to_xlsx
		@export = report_type.find_or_initialize_by_key(@cache_key)
		if @export.generated? && params[:generate].nil?
			if request.xhr?
				headers["Content-Type"] = "text/javascript"
				render :js => "window.location = '#{url_for(:format => 'xlsx', :report => @report)}'"
			else
        begin
          filename = @filename || "participants.xlsx"
          send_data @export.file.read, :filename => filename, :disposition => 'inline', :type => @export.mime_type.to_s
        rescue
          flash[:error] = "The file could not be read from the server. Please try regenerating the export."
          redirect_to :back
        end
			end
		else
			respond_to_generate_xlsx
		end
	end
  
	def respond_to_generate_xlsx
		@export = report_type.find_or_initialize_by_key(@cache_key)
		@export.format = "xlsx"
		@export.object_ids = report_object_ids
		@export.reset_to_ungenerated
		@export.status = "initializing"
		@export.save
    logger.debug { @export.to_yaml }
    logger.debug { @export.errors.to_yaml }
		@export.generate_in_background!
		flash[:notice] = "We are generating your Excel file for you. Please wait."
		
		if request.xhr?
			headers["Content-Type"] = "text/javascript"
			return render(:template => "participants/check_export_status.js.erb", :format => 'js')
		else
			return redirect_to(:back, :format => 'html')
		end
	end

  def report_type
    case params[:report]
    when "test_score_summaries" then TestScoresReport
    when "college_applications" then CollegeApplicationsReport
    else ParticipantsReport
    end
  end
  
  def report_object_ids
    @participants = @participants.unpaginate
    case params[:report]
    when "test_score_summaries" then @participants.collect(&:test_scores).flatten.collect(&:id)
    when "college_applications" then @participants.collect(&:college_applications).flatten.collect(&:id)
    else @participants.collect(&:id)
    end
  end
    
end
