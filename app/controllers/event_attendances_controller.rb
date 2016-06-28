class EventAttendancesController < EventsController
  before_filter :fetch_event
  before_filter :fetch_attendee, only: [:edit, :destroy]
  before_filter :declare_audience, only: [:index, :checkin, :auto_complete_for_person_fullname]
  skip_before_filter :redirect_to_rsvp_if_not_admin

  skip_before_filter :check_authorization, only: [:index, :checkin, :checkin_new_participant, :create, :update, :destroy, :auto_complete_for_person_fullname]
  before_filter :check_authorization_basic, only: [:index, :checkin, :checkin_new_participant, :auto_complete_for_person_fullname]
  before_filter :check_authorization_conditional, only: [:create, :update, :destroy]
  before_filter :attendee_params, only: [:create, :update]

  protect_from_forgery only: [:create, :update, :destroy] 

  def index
    @attendees = @event.attendees

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @attendees }
      format.xml  { render xml: @attendees }
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
      @attendee = @event.attendees.create(person_id: @person.try(:id), attended: true)
    end
    respond_to do |format|
      format.html { redirect_to action: 'checkin' }
      format.js
    end
  end

  def checkin_new_volunteer
    @person = Volunteer.new(params[:new_volunteer])
    @person.validate_name = true
    if @person.save
      @attendee = @event.attendees.create(person_id: @person.try(:id), attended: true)
    end
    respond_to do |format|
      format.html { redirect_to action: 'checkin' }
      format.js
    end
  end
  
  def edit
  end

  def create
    save_attendance
  end
  
  def update
    save_attendance
  end

  def destroy
    @attendee.destroy

    respond_to do |format|
      format.html { redirect_to(admin_attendees_url) }
      format.xml  { head :ok }
    end
  end
  
  def auto_complete_for_person_fullname
    fullname = params[:person][:fullname].downcase rescue ""
    conditions = %w[firstname lastname display_name uw_net_id].collect{|c| "#{c} LIKE :fullname" }
    matches = { fullname: "#{fullname}%" }

    if fullname.include?(",")
      conditions << "(lastname LIKE :lastname AND (firstname LIKE :firstname OR nickname LIKE :firstname))"
      name_parts = fullname.split(/\s*,\s*/)
      matches.merge!(lastname: "#{name_parts[0]}%", firstname: "#{name_parts[1]}%")
      
    elsif fullname.include?(" ")
      conditions << "(lastname LIKE :lastname AND (firstname LIKE :firstname OR nickname LIKE :firstname))"
      name_parts = fullname.split
      matches.merge!(firstname: "#{name_parts[0]}%", lastname: "#{name_parts[1]}%")
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

  def save_attendance
    @attendee = @event.attendees.where(person_id: attendee_params[:person_id]).first_or_create

    if @attendee.update_attributes(attendee_params)
      flash[:notice] = "Saved"
      status = :ok
    else
      flash[:error] = "There was an error saving the attendance. Please try again, or contact an administrator if the issue persists."
      status = :unprocessable_entity
    end

    respond_to do |format|
      format.html { redirect_to(event_event_attendances_path(@event, audience: @attendee.try(:person).try(:class))) }
      format.js   { render 'upsert', status: status }
      format.json { render json: @attendee, status: status }
      format.xml  { head status }
    end
  end

  
  def fetch_event
    @event = Event.find params[:event_id]
  end

  def fetch_attendee
    @attendee = @event.attendees.find(params[:id])
  end
  
  def declare_audience
    @audience = params[:audience].try(:classify).try(:constantize) || Participant
    if @audience == Mentor || @audience == Volunteer
      @audiences = [Mentor, Volunteer]
    else
      @audiences = [Participant, Student]
    end 
  end
  
  # Allow any fully registered Mentor (or admin) to access
  def check_authorization_basic
    unless @current_user && (@current_user.admin? || (@current_user.person.try(:respond_to?, :passed_basics?) && @current_user.person.try(:passed_basics?)))
      render_error("You are not allowed to access that page.")
    end
  end

  # Mentors and volunteers can check-in Participants and Students, but only privileged users
  # can check-in Mentors and Volunteers
  def check_authorization_conditional
    person = (attendee_params[:person_id] && Person.find(attendee_params[:person_id])) || @attendee.try(:person)
    if person
      return check_authorization_basic if person.class == Participant || person.class == Student
      return check_authorization
    end
    render_error("You are not allowed to access that page.")
  end
  
  def attendee_params
    params[:attendee] || params[:event_attendance]
  end
end
