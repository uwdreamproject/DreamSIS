class VisitsController < ApplicationController

  before_filter :fetch_high_school
  before_filter :fetch_quarter
  
  def index
    @visits = @high_school.visits.for(@quarter)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @visits }
    end
  end

  def show
    @visit = @high_school.visits.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @visit }
    end
  end

  def new
    @visit = @high_school.visits.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @visit }
    end
  end

  def edit
    @visit = @high_school.visits.find(params[:id])
  end
  
  def attendance
    return redirect_to attendance_high_school_visits_path(@high_school, @quarter) if params[:quarter_id] == "new"
    @participants = []
    @showing = []
    if !params[:show] || params[:show].include?("participants")
      @participants << @high_school.participants.find(:all, 
                                                      :conditions => { :grad_year => @quarter.participating_cohort },
                                                      :order => "inactive")
      @showing << :participants
    end                              
    if params[:show] && params[:show].include?("mentors")
      @participants << @high_school.mentor_quarter_groups.for(@quarter).collect(&:mentors)
      @showing << :mentors
    end
    @participants.flatten!

    @visits = @high_school.events(@quarter, @showing)
  end

  def update_attendance
    if params[:attendance]
      params[:attendance].each do |participant_id,attendance_attributes|
        @participant = Person.find(participant_id)
        attendance_attributes.each do |event_id,attended|
          @event = Event.find(event_id)
          event_attendance = @participant.event_attendances.find_or_create_by_event_id(@event.id)
          event_attendance.update_attribute(:attended, attended)
        end
      end
      flash[:notice] = "Attendance data saved."
    end

    if params[:rsvp]
      params[:rsvp].each do |participant_id,attendance_attributes|
        @participant = Person.find(participant_id)
        attendance_attributes.each do |event_id,rsvp|
          @event = Event.find(event_id)
          event_attendance = @participant.event_attendances.find_or_create_by_event_id(@event.id)
          event_attendance.update_attribute(:rsvp, rsvp)
        end
      end
      flash[:notice] = "Attendance data saved."
    end

    respond_to do |format|
      format.html { redirect_to :action => "attendance" }
      format.js
    end
  end

  def create
    @visit = @high_school.visits.new(params[:visit])

    respond_to do |format|
      if @visit.save
        flash[:notice] = 'Visit was successfully created.'
        format.html { redirect_to(high_school_visit_url(@high_school, @quarter, @visit)) }
        format.xml  { render :xml => @visit, :status => :created, :location => @visit }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @visit.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @visit = @high_school.visits.find(params[:id])

    respond_to do |format|
      if @visit.update_attributes(params[:visit])
        flash[:notice] = 'Visit was successfully updated.'
        format.html { redirect_to(high_school_visit_url(@high_school, @quarter, @visit)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @visit.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @visit = @high_school.visits.find(params[:id])
    @visit.destroy

    respond_to do |format|
      format.html { redirect_to(high_school_visits_url(@high_school, @quarter)) }
      format.xml  { head :ok }
    end
  end
  
  protected
  
  def fetch_high_school
    @high_school = HighSchool.find(params[:high_school_id])
  end
  
  def fetch_quarter
    if params[:new_quarter_id]
      if params[:new_quarter_id].is_a?(String)
        abbrev = params[:new_quarter_id]
      else
        abbrev = "#{params[:new_quarter_id][:quarter_code_abbreviation]}#{params[:new_quarter_id][:year]}"
      end
    else
      abbrev = params[:quarter_id]
    end
    @quarter = Quarter.find_or_create_by_abbrev(abbrev)
  end
  
end