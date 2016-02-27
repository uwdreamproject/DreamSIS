class ParticipantSignupController < ApplicationController
	before_filter :fetch_participant

	def index
		redirect_to :action => :participant_signup_intake_form
	end

	def intake_form
	end



	private 

	def fetch_participant
		@participant = @current_user.person
	end
end
