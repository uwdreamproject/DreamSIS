class ParticipantBulkActionsController < ParticipantsController
  before_filter :fetch_participants
  before_filter :check_authorization
  before_filter :check_privileged, :only => :process_assign_mentor
  before_filter :validate_emails, :only => :send_login_links
  
	def send_email
		@emails = @participants.collect(&:email).flatten.uniq.compact.delete_if(&:blank?)
		if @emails.empty?
			flash[:error] = "You must select at least one record with an e-mail address."
			render :js => "updateFlashes({ error: '#{flash[:error]}' })"
		else
      flash[:notice] = "Sent #{@emails.count} #{"e-mail address".pluralize(@emails.count)} to your e-mail program."
			render :js => "window.location.href = 'mailto:#{j @emails.join(",")}';"
		end
	end
  
  def add_note
    @note = Note.new
    respond_to do |format|
      format.js
    end
  end
  
  def flag_for_followup
    @note = Note.new(:needs_followup => true)
    respond_to do |format|
      format.js { render :action => "add_note"}
    end    
  end
  
  def process_add_note
    @notes = { :success => [], :error => [] }
    for participant in @participants
      note = participant.notes.create(params[:note])
      if note.valid?
        @notes[:success] << note
      else
        @notes[:error] << note
        flash[:error] = "Sorry, we couldn't save your note: #{note.errors.full_messages.to_sentence}"
      end
    end
    
    respond_to do |format|
      format.js
    end
  end
  
  def check_in_event
    respond_to do |format|
      format.js
    end    
  end
  
  def assign_mentor
    respond_to do |format|
      format.js
    end
  end
  
  def process_assign_mentor
    @mentor = Mentor.find params[:mentor_id]
    
    @mentor_participants = { :success => [], :error => [] }
    for participant in @participants
      begin
        participant.mentors << @mentor
        @mentor_participants[:success] << participant
      rescue ActiveRecord::RecordInvalid => e
        @mentor_participants[:error] << participant
        flash[:error] = "#{@mentor.fullname} is already assigned to #{participant.fullname}"
      end
    end
  rescue ActiveRecord::RecordNotFound => e
    flash[:error] = "Please specify a #{Customer.mentor_label} to assign."
    return render :text => "Error"
  end
  
  def assign_to_group
    @participant_groups = ParticipantGroup.find(params[:participant_group_ids].split(","))
    respond_to do |format|
      format.js
    end
  end
  
  def process_assign_to_group
    @participant_group = ParticipantGroup.find(params[:participant_group_id])
    flash[:error] = "Could not find participant group with that ID" unless @participant_group
    
    for participant in @participants
      participant.participant_group = @participant_group
      participant.save
    end
  end

  def send_login_links
    return render_error_context("You are not authorized to perform that action") unless Customer.allow_participant_login

    errors = []
    @participants.each do |participant|
      token = participant.generate_login_token!
      login_link = map_login_url(participant, token)
      begin
        participant.send_login_link(login_link)
      rescue Mandrill::Error => e
        errors << participant.email
      end
    end

    error_count = errors.count
    success_count = @participants.count - error_count
    if error_count > 0
      error_text = "#{success_count} #{"email".pluralize(success_count)} sent successfully. The following could not be sent: "
      error_text << errors.join(", ")

      render_error_context(error_text)
    else
      flash[:notice] = "#{success_count} login #{"email".pluralize(success_count)} successfully sent."
      render :js => "updateFlashes({ notice: '#{flash[:notice]}' })"
    end
  end
  
  protected
  
  def fetch_participants
    participant_ids = params[:selected] ? params[:selected]["Participant"].keys : params[:participant_ids]
    @participants = Participant.find(participant_ids)
  end
  
  def check_authorization
    for participant in @participants
      unless @current_user && @current_user.can_edit?(participant)
        return render_error("You are not allowed to edit one of the selected participants.")
      end
    end
  end

  def check_privileged
    unless @current_user.admin? || @current_user.person.current_lead?
      error_text = "You are not authorized to perform that action."
      render_error_context(error_text)
    end
  end

  def validate_emails
    blank_participants = @participants.select { |p| p.email.blank? }
    emails = @participants.collect(&:email)
    error_text = "Error: "
    if blank_participants.any?
      blank_count = blank_participants.count
      error_text << blank_participants.collect(&:fullname).join(", ")
      error_text << " #{blank_count == 1 ? "has" : "have" } no email #{"address".pluralize(blank_count)} on file."
      error_text << " Ensure all #{Customer.mentees_label} have valid email addresses."
    elsif emails.uniq.count != @participants.count
      duplicate_emails = (emails - emails.uniq).uniq
      error_text << "Multiple #{Customer.mentees_label} have the following email addresses:"
      error_text << duplicate_emails.join(", ")
      error_text << ". Ensure there are no #{Customer.mentees_label} with duplicate email addresses."
    else
      return true
    end

    render_error_context(error_text)
  end

  def render_error_context(error_text)
    if request.xhr?
      flash[:error] = error_text
      return render :js => "updateFlashes({ error: '#{j flash[:error]}' })"
    else
      return render_error(error_text)
    end
  end

end
