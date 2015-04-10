class ParticipantBulkActionsController < ParticipantsController
  before_filter :fetch_participants
  before_filter :check_authorization
  
	def send_email
		@emails = @participants.collect(&:email).flatten.compact.uniq
		if @emails.empty?
			flash[:error] = "You must select at least one record with an e-mail address."
			render :text => flash[:error], :status => 200
		else
      # flash[:notice] = "Sent #{@template.pluralize(@emails.count, "e-mail address")} to your e-mail program."
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
  
end