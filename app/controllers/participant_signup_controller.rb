class ParticipantSignupController < ApplicationController
	before_filter :fetch_participant
  	skip_before_filter :check_authorization	


	def index
	  redirect_to :action => :participant_signup_intake_form
	end

	def intake_form
	  if request.put?
     	@participant.intake_form_signature = params[:participant][:intake_form_signature]
     	@participant.intake_form_signed_at = params[:participant][:intake_form_signed_at] == "1" ? Time.now : nil
     	if @participant.save
          flash[:notice] = "Your intake form was successfully received. Thank you."
          @participant.completed_intake_form = true
      	end
	  end
	end

	private 

	def fetch_participant
      @participant = @current_user.person
	end
end
