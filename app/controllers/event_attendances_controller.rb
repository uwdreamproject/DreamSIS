class EventAttendancesController < EventsController
  before_filter :fetch_event
  before_filter :declare_audience, :only => [:index, :checkin, :auto_complete_for_person_fullname]
  skip_before_filter :redirect_to_rsvp_if_not_admin

  skip_before_filter :check_authorization, :only => [:index, :checkin, :create, :update, :auto_complete_for_person_fullname]
  before_filter :check_checkin_authorization, :only => [:index, :checkin, :create, :update, :auto_complete_for_person_fullname]

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

  # def show
  #   @attendee = @event.attendees.find(params[:id])
  # 
  #   respond_to do |format|
  #     format.html # show.html.erb
  #     format.xml  { render :xml => @attendee }
  #   end
  # end

  # def new
  #   @attendee = @event.attendees.new
  # 
  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.xml  { render :xml => @attendee }
  #   end
  # end
  
  def edit
    @attendee = @event.attendees.find(params[:id])
  end

  def create
    @attendee = @event.attendees.new(params[:attendee] || params[:event_attendance])

    respond_to do |format|
      if @attendee.save
        flash[:notice] = "#{@attendee.fullname} was successfully checked in."
        format.html { redirect_to(@attendee) }
        format.js
        format.json { render :json => @attendee }
        format.xml  { render :xml => @attendee, :status => :created, :location => @attendee }
      else
        format.html { render :action => "new" }
        format.js   { flash[:error] = @attendee.errors.full_messages.to_sentence }
        format.xml  { render :xml => @attendee.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    # @attendee = @event.attendees.find(params[:id])
    @attendee = EventAttendance.find(params[:id])
    @attendee.admin = params[:event_attendance].try(:[], :admin) if params[:event_attendance].try(:[], :admin)

    respond_to do |format|
      if @attendee.update_attributes(params[:attendee] || params[:event_attendance])
        flash[:notice] = "#{@attendee.fullname} was successfully #{ @attendee.attended_changed? ? "checked in" : "updated" }."
        format.html { redirect_to(event_event_attendances_path(@event, :audience => @attendee.try(:person).try(:class))) }
        format.js
        format.json { render :json => @attendee }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @attendee.errors, :status => :unprocessable_entity }
      end
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
    fullname.gsub!(", ", ",")
    conditions = %w[firstname lastname display_name uw_net_id].collect{|c| "LOWER(#{c}) LIKE :fullname" }
    conditions << "LOWER(#{db_concat(:firstname, ' ', :lastname)}) LIKE :fullname" if fullname.include?(" ")
    conditions << "LOWER(#{db_concat(:lastname, ',', :firstname)}) LIKE :fullname" if fullname.include?(",")
    
    @people = Person
      .where(type: @audiences.collect(&:to_s))
      .where([conditions.join(" OR "), {:fullname => "#{fullname}%"}])
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
    unless @current_user && (@current_user.admin? || (@current_user.person.try(:respond_to?, :passed_basics?) && @current_user.person.try(:passed_basics?)))
      render_error("You are not allowed to access that page.")
    end
    
  end
  
end