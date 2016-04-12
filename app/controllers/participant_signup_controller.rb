class ParticipantSignupController < ApplicationController
  before_filter :fetch_participant, :check_authorization

  def index
    redirect_to :action => :participant_signup_intake_form
  end

  def intake_form
    if request.put?
      @participant.intake_form_signature = params[:participant][:intake_form_signature]
      @participant.assign_attributes(params[:participant])
      
      for attribute in %w[firstname lastname email high_school_id]
        @participant.send("reset_#{attribute}!") unless @current_user.can_edit?(@participant, attribute)
      end
      
      if @participant.save
        flash[:notice] = "Your information was successfully updated. Thank you."
        redirect_to root_url
      else
        flash[:error] = "Sorry, we couldn't save your information. Please try again."
      end
    end
  end

  private 

  def fetch_participant
    @participant = @current_user.person
  end

  def check_authorization
    unless current_user && current_user.person_type == "Participant" && current_user.person == @participant
      return render_error("You are not allowed to view this form")
    end    
  end
end
