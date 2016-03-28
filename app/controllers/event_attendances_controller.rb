class EventAttendancesController < EventsController
  before_filter :fetch_event
  before_filter :declare_audience, :only => [:index, :checkin, :auto_complete_for_person_fullname]
  skip_before_filter :redirect_to_rsvp_if_not_admin

  skip_before_filter :check_authorization, :only => [:index, :checkin, :create, :update, :auto_complete_for_person_fullname]
  before_filter :check_checkin_authorization, :only => [:index, :checkin, :create, :update, :auto_complete_for_person_fullname]
  before_filter :attendee_params, :only => [:create, :update]

  protect_from_forgery :only => [:create, :update, :destroy] 

  def index
    @attendees = @event.attendees

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @attendees }
      format.xml  { render :xml => @attendees }
    end
  end

  def checkin
    @layout_in_blocks = true
    
    respond_to do |format|
      format.html
    end
  end
  
  def checkin_new_participant
    @person = Student.new(params[:new_participant])
    @person.validate_name = true
    if !@person.high_school.nil? && @person.save
      @attendee = @event.attendees.create(:person_id => @person.try(:id), :attended => true)
    end
    respond_to do |format|
      format.html { redirect_to :action => 'checkin' }
      format.js
    end
  end

  def checkin_new_volunteer
    @person = Volunteer.new(params[:new_volunteer])
    @person.validate_name = true
    if @person.save
      @attendee = @event.attendees.create(:person_id => @person.try(:id), :attended => true)
    end
    respond_to do |format|
      format.html { redirect_to :action => 'checkin' }
      format.js
    end
  end
  
  def edit
    @attendee = @event.attendees.find(params[:id])
  end

  def create
    upsert
  end
  
  def update
    upsert
  end

  def upsert
    @attendee = EventAttendance.where(person_id: attendee_params[:person_id], event_id: @event.id).first_or_create
    @attendee.update_attributes(attendee_params)

    if @attendee.save
      flash[:notice] = "Saved"
    else
      flash[:error] = "There was an error saving the attendance. Please try again."
    end

    respond_to do |format|
      format.html { redirect_to(event_event_attendances_path(@event, :audience => @attendee.try(:person).try(:class))) }
      format.js   { render 'upsert' }
      format.json { render :json => @attendee }
      format.xml  { head :ok }
    end
  end

  def destroy
    @attendee = @event.attendees.find(params[:id])
    @attendee.destroy

    respond_to do |format|
      format.html { redirect_to(admin_attendees_url) }
      format.xml  { head :ok }
    end
  end
  
  def auto_complete_for_person_fullname
    fullname = params[:person][:fullname].downcase rescue ""
    conditions = %w[firstname lastname display_name uw_net_id].collect{|c| "#{c} LIKE :fullname" }
    matches = { :fullname => "#{fullname}%" }

    if fullname.include?(",")
      conditions << "(lastname LIKE :lastname AND (firstname LIKE :firstname OR nickname LIKE :firstname))"
      name_parts = fullname.split(/\s*,\s*/)
      matches.merge!(:lastname => "#{name_parts[0]}%", :firstname => "#{name_parts[1]}%")
      
    elsif fullname.include?(" ")
      conditions << "(lastname LIKE :lastname AND (firstname LIKE :firstname OR nickname LIKE :firstname))"
      name_parts = fullname.split
      matches.merge!(:firstname => "#{name_parts[0]}%", :lastname => "#{name_parts[1]}%")
    end
    
    @people = Person
      .where(type: @audiences.collect(&:to_s))
      .where([conditions.join(" OR "), matches])
      .limit(30)
    @people = @people.includes(:high_school) if @audiences.include?(Participant) || @audiences.include?(Student)      
    @event_attendances = Hash[EventAttendance.where(event_id: @event.id, person_id: @people.collect(&:id)).map{|ea| [ea.person_id, ea]}]
    
    respond_to do |format|
      format.js
    end
  end
  
  
  protected
  
  def fetch_event
    @event = Event.find params[:event_id]
  end
  
  def declare_audience
    @audience = params[:audience].try(:classify).try(:constantize) || Participant
    if @audience == Mentor || @audience == Volunteer
      @audiences = [Mentor, Volunteer]
    else
      @audiences = [Participant, Student]
    end 
  end
  
  def check_checkin_authorization
    unless @current_user && (@current_user.admin? || (@current_user.person.try(:respond_to?, :current_lead?) && @current_user.person.try(:current_lead?)))
      render_error("You are not allowed to access that page.")
    end
    
  end
  
  def attendee_params
    params[:attendee] || params[:event_attendance]
  end
  
end
