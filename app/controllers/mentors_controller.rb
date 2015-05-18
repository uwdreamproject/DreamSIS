class MentorsController < ApplicationController  
  protect_from_forgery :except => [:auto_complete_for_mentor_fullname] 
  skip_before_filter :login_required, :check_authorization, :save_user_in_current_thread, :check_if_enrolled, :only => [:check_if_valid_van_driver]

  def index
    return redirect_to Mentor.find(params[:id]) if params[:id]
    @mentors = Mentor.page(params[:page])

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
                            :conditions => ["(rsvp = ? OR attended = ?)", true, true]
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
  
  def send_login_link
    @mentor = Mentor.find(params[:id])
    result = @mentor.send_login_link(map_login_url(@mentor, @mentor.generate_login_token!))
    
    if result && result.first["status"] == 'sent'
      flash[:notice] = "Login link sent successfully."
    else
      flash[:error] = "Error sending login link: #{result['reject_reason']}"
    end
    redirect_to @mentor
  end
  
  def remove_participant
    @mentor = Mentor.find(params[:id])
    @mentor_participant = @mentor.mentor_participants.find(params[:mentor_participant_id])
    
    respond_to do |format|
      if @mentor_participant.destroy
        flash[:notice] = "#{@mentor_participant.participant.fullname} was removed from #{@mentor.fullname}'s list of mentees."
        format.html { redirect_back_or_default(:back) }
        format.xml  { head :ok }
        format.js
      else
        flash[:error] = "Sorry, but we couldn't remove the mentee successfully."
        format.html { redirect_back_or_default(:back) }
        format.xml  { render :xml => @mentor_participant.errors, :status => :unprocessable_entity }
      end
    end
  end

  def photo
    begin
      @mentor = Mentor.find(params[:id])
			if @mentor.avatar?
				av = params[:size] ? @mentor.avatar.versions[params[:size].to_sym] : @mentor.avatar
				return send_default_photo(params[:size]) if av.nil?
        return send_data(av.read, :disposition => 'inline', :type => 'image/jpeg') rescue nil
        # return redirect_to(av.url) rescue nil
      end
      if avatar_image_url = @mentor.users.try(:first).try(:person).try(:avatar_image_url)
				return redirect_to(avatar_image_url)
			elsif !@mentor.reg_id.nil?
	      student_photo = StudentPhoto.find(@mentor.reg_id)
	      file_path = student_photo.try(:image_path, params[:size])
			else
				file_path = nil
			end
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
                                          {:fullname => "%#{params[:term].downcase}%"}])

    render :json => @mentors.map { |mentor| 
      {
        :id => mentor.id, 
        :value => h(mentor.fullname),
        :klass => mentor.class.to_s.underscore, 
        :fullname => h(mentor.fullname),
        :secondary => h(mentor.email),
        :tertiary => h((Customer.current_customer.customer_label(mentor.class.to_s.underscore, :titleize => true) || result.class.to_s).titleize)
      }
    }    
  end
  
  def onboarding
    @term = Term.find(params[:term_id])
    @group_ids = @term.mentor_term_groups.collect(&:id)
    @mentors = @term.mentors(sort = :lastname)
    if params[:group_id]
      mentor_term_group = MentorTermGroup.find(params[:group_id])
      @group_title = mentor_term_group.title
      @mentors = mentor_term_group.mentors
    else
      @mentors = @term.mentors(sort = :lastname)
    end
    respond_to do |format|
      format.html
      format.js { render :partial => "table_ajax", :locals => {:row_partial => "mentor_onboarding"} }
    end
  end

  def sidebar_form_update
    @mentor = Mentor.find(params[:id])
    @mentor.validate_name = true

    respond_to do |format|
      if @mentor.update_attributes(params[:mentor])
        flash[:notice] = 'Mentor was successfully updated.'
        format.html { render :partial => params[:row_partial], :object => @mentor }
      else
        flash[:error] = "Error updating mentor."
      end
    end
  end

  def onboarding_form
    @mentor = Mentor.find(params[:id])
    respond_to do |format|
      format.html { render :partial => "onboarding_form"}
    end
  end

  def onboarding_textblocks
    @term = Term.find(params[:term_id])
    @mentors = @term.mentors(sort = :lastname)
    respond_to do |format|
      format.json { render :json => { :background_check => h(view_context.background_check_textblock(@mentors)),
                                      :sex_offender_check => h(view_context.sex_offender_check_textblock(@mentors)) } }
    end
  end

  def driver_edit_form
    @mentor = Mentor.find(params[:id])
    respond_to do |format|
      format.html { render :partial => "driver_edit_form"}
    end
  end

  def driver_training_status
    if Customer.link_to_uw?
      render :json => UwDriver.check_uwfs_training(params[:id])
    else
      return render :text => "Action not defined for current customer", :status => 400
    end
  end

  def event_status
    @term = Term.find(params[:term_id])
    @mentors = @term.mentors
  end
  
  def leads
    @term = (Term.find(params[:new_term_id] || params[:term_id]) rescue nil) || Term.current_term || Term.allowing_signups.try(:first) || Term.last
    @high_schools = HighSchool.partners
  end
  
  def van_drivers
    @term = (t = params[:new_term_id] || params[:term_id]) ? Term.find(t) : Term.current_term
    if params[:group_id]
      @group_title = MentorTermGroup.find(params[:group_id]).title
      @page_header_title = @group_title
      @mentors = Mentor.valid_van_drivers(@term.id, params[:group_id])
      @ajax_load = false
    else
      @mentors = Mentor.valid_van_drivers(@term.id)
      @page_header_title = @term.is_a?(Quarter) ? @term.title : @term.to_param
      @group_ids = @term.mentor_term_groups.collect(&:id)
      @ajax_load = !@mentors.empty?
    end
    respond_to do |format|
      format.html
      format.js { render :partial => "table_ajax", :locals => { :row_partial => "mentor_driver" } }
    end
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
		filename = size == "thumb" ? "blank_avatar_thumb.png" : "blank_avatar.png"
    send_file File.join(Rails.root, "public", "images", filename), 
              :disposition => 'inline', :type => 'image/png', :status => 404
  end
  
end
