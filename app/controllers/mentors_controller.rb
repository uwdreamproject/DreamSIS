class MentorsController < ApplicationController
  
  skip_before_filter :login_required, :check_authorization, :save_user_in_current_thread, :check_if_enrolled, :only => [:check_if_valid_van_driver]
  
  def index
    @mentors = Mentor.paginate :all, :page => params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mentors }
      format.xls { 
        @mentors = Mentor.all
        render :action => 'index', :layout => 'basic' 
      }
    end
  end

  def show
    @mentor = Mentor.find(params[:id]) rescue Volunteer.find(params[:id])
    @participants = @mentor.try(:participants) if @mentor.respond_to?(:participants)
    @event_attendances = @mentor.event_attendances.find(:all, 
                            :include => :event, 
                            :joins => :event, 
                            :conditions => ["events.type IS NULL AND (rsvp = ? OR attended = ?)", true, true]
                          )
    @layout_in_blocks = true

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mentor }
    end
  end

  def background_check_form_responses
    @mentor = Mentor.find(params[:id]) rescue Volunteer.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @mentor }
    end
  end


  def new
    @mentor = Mentor.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mentor }
    end
  end

  def edit
    @mentor = Mentor.find(params[:id])
  end

  def create
    @mentor = Mentor.new(params[:mentor])
    @mentor.validate_name = true

    respond_to do |format|
      if @mentor.save
        flash[:notice] = 'Mentor was successfully created.'
        format.html { redirect_to(@mentor) }
        format.xml  { render :xml => @mentor, :status => :created, :location => @mentor }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mentor.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @mentor = Mentor.find(params[:id])
    @mentor.validate_name = true

    respond_to do |format|
      if @mentor.update_attributes(params[:mentor])
        flash[:notice] = 'Mentor was successfully updated.'
        format.html { redirect_to(@mentor) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mentor.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def remove_participant
    @mentor = Mentor.find(params[:id])
    @mentor_participant = @mentor.mentor_participants.find(params[:mentor_participant_id])
    
    respond_to do |format|
      if @mentor_participant.destroy
        flash[:notice] = "#{@mentor_participant.participant.fullname} was removed from #{@mentor.fullname}'s list of mentees."
        format.html { redirect_to :back }
        format.xml  { head :ok }
        format.js
      else
        flash[:error] = "Sorry, but we couldn't remove the mentee successfully."
        format.html { redirect_to :back }
        format.xml  { render :xml => @mentor_participant.errors, :status => :unprocessable_entity }
      end
    end
  end

  def photo
    begin
      @mentor = Mentor.find(params[:id])
      return send_default_photo(params[:size]) if @mentor.reg_id.nil?
      student_photo = StudentPhoto.find(@mentor.reg_id)
      file_path = student_photo.try(:image_path, params[:size])
      if file_path
        send_file file_path, :disposition => 'inline', :type => 'image/jpeg' # TODO :x_sendfile => true in production
      else
        send_default_photo(params[:size])
      end
    rescue ActiveResource::ResourceNotFound
      send_default_photo(params[:size])
    end
  end
  
  def auto_complete_for_mentor_fullname
    @mentors = Mentor.find(:all, 
                          :conditions => ["LOWER(firstname) LIKE :fullname 
                                            OR LOWER(lastname) LIKE :fullname
                                            OR LOWER(display_name) LIKE :fullname
                                            OR LOWER(uw_net_id) LIKE :fullname", 
                                          {:fullname => "%#{params[:mentor][:fullname].downcase}%"}])
    respond_to do |format|
      format.js
    end
  end
  
  def onboarding
    @quarter = Quarter.find(params[:quarter_id])
    @mentors = @quarter.mentors
  end

  def event_status
    @quarter = Quarter.find(params[:quarter_id])
    @mentors = @quarter.mentors
  end
  
  def leads
    @quarter = Quarter.find(params[:quarter_id])
    @high_schools = HighSchool.partners
  end
  
  def van_drivers
    @mentors = Mentor.valid_van_drivers
  end
  
  def check_if_valid_van_driver
    @mentor = Mentor.find_by_husky_card_rfid(params[:tag])
    if @mentor && @mentor.valid_van_driver?
      render :text => '1', :status => 200
    else
      render :text => '0', :status => 203
    end
  end
  
  protected
  
  def send_default_photo(size)
    send_file File.join(RAILS_ROOT, "public", "images", "blank_avatar.png"), 
              :disposition => 'inline', :type => 'image/png', :status => 404
  end  
  
end