class WelcomeController < ApplicationController
  skip_before_filter :check_authorization
  before_filter :check_identity
  
  def index
    redirect_to :action => "mentor" if @current_user.person.is_a?(Mentor)
    @person = @current_user.person
    @events = @person.event_attendances.future_attending.collect(&:event)
    @layout_in_blocks = true
  end

  def mentor
    @mentor = @current_user.person
    redirect_to mentor_signup_basics_path unless @mentor.passed_basics?
    @my_mentees = @mentor.try(:participants)
    @layout_in_blocks = true
    @high_schools = @mentor.current_mentor_quarter_groups.collect(&:location).flatten.uniq.compact
    @high_school = @mentor.current_lead_at.first
    @events = @mentor.event_attendances.future_attending.collect(&:event)
    @participants = Participant.in_cohort(Participant.current_cohort).in_high_school(@high_school.try(:id)) if @high_school
    @participant_groups = ParticipantGroup.find :all, :conditions => { :location_id => @high_school.try(:id)} if @high_school
  end

  protected
  
  def check_identity
    redirect_to choose_identity_path if @current_user.person.class == Person || @current_user.person.nil?
  end

end
