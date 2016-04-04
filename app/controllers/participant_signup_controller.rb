class ParticipantSignupController < ApplicationController
  before_filter :fetch_participant
  skip_before_filter :check_authorization	

  def index
  	redirect_to :action => :participant_signup_intake_form
  end

  def intake_form
	  unless current_user && current_user.person.can_view?(@participant)
      return render_error("You are not allowed to view this form")
    end

	  if request.put?
      @participant.intake_form_signature = params[:participant][:intake_form_signature]
      if @participant.update_attributes(params[:participant])
        flash[:notice] = "Your information was successfully updated. Thank you."
      	redirect_to root_url
      end
	  end
	end

  private 

  def fetch_participant
    @participant = @current_user.person
  end

end
