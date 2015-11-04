class ParticipantBulkActionsController < ParticipantsController
  before_filter :fetch_participants
  before_filter :check_authorization
  before_filter :check_privileged, :only => :process_assign_mentor
  
	def send_email
		@emails = @participants.collect(&:email).flatten.uniq.compact.delete_if(&:blank?)
		if @emails.empty?
			flash[:error] = "You must select at least one record with an e-mail address."
			render :js => "updateFlashes({ error: '#{flash[:error]}' })"
		else
      flash[:notice] = "Sent #{@emails.count} #{"e-mail address".pluralize(@emails.count)} to your e-mail program."
			render :js => "window.location.href = 'mailto:#{@emails.join(",")}';"
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
      if request.xhr?
        flash[:error] = error_text
        return render :text => "Error", :status => 403
      else
        return render_error(error_text)
      end
    end
  end
  
end
