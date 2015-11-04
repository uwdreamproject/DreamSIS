class WelcomeController < ApplicationController
  skip_before_filter :check_authorization
  before_filter :check_identity
  before_filter :apply_customer_styles
  
  def index
    redirect_to :action => "mentor" if @current_user.person.is_a?(Mentor)
    @person = @current_user.person
    @events = @person.event_attendances.future_attending.collect(&:event)
    @event_groups = EventGroup.where(allow_external_volunteers: true)
    # @layout_in_blocks = true
    apply_extra_stylesheet
    apply_extra_footer_content
  end

  def mentor
    @mentor = @current_user.person
    if !@mentor.passed_basics?
      redirect_to mentor_signup_basics_path
    end
    @my_mentees = @mentor.try(:participants)
    @layout_in_blocks = true
    @high_schools = @current_user.current_locations
    @high_school = @mentor.current_lead_at.first
    @events = @mentor.event_attendances.future_attending.collect(&:event)
    @participants = Participant.in_cohort(Participant.current_cohort).in_high_school(@high_school.try(:id)).page(params[:page]) if @high_school
    @participant_groups = ParticipantGroup.find :all, :conditions => { :location_id => @high_school.try(:id)} if @high_school
    @report = params[:report].blank? ? "basics" : ERB::Util.html_escape(params[:report])
  end

  protected
  
  def check_identity
    redirect_to choose_identity_path if @current_user.person.class == Person || @current_user.person.nil?
  end

end
