class VisitsController < ApplicationController
  before_filter :fetch_high_school
  before_filter :fetch_term
  
  skip_before_filter :check_authorization, :only => [:attendance, :update_attendance]
  
  def index
    @visits = @high_school.visits.for(@term)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @visits }
    end
  end

  def show
    @visit = @high_school.visits.find(params[:id])
    @event = @visit

    respond_to do |format|
      format.html
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
    @participants = []
    @showing = []
    @current_cohort = params[:cohort] || @term.participating_cohort
    if !params[:show] || params[:show].include?("participants")
      @participants << @high_school.participants.find(:all,
                                                      :conditions => { :grad_year => @current_cohort },
                                                      :order => "inactive")
      @showing << :participants
    end
    if params[:show] && params[:show].include?("mentors")
      @participants << @high_school.mentor_term_groups.for(@term).collect(&:mentors)
      @showing << :mentors
    end
    @participants.flatten!
    limit = params[:limit] || 5
    @visits = @high_school.events(@term, @showing, true, limit).page(params[:page])
  end
  
  def create
    @visit = @high_school.visits.new(params[:visit])

    respond_to do |format|
      if @visit.save
        flash[:notice] = 'Visit was successfully created.'
        format.html { redirect_to(high_school_visit_url(@high_school, @visit)) }
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
        format.html { redirect_to(high_school_visit_url(@high_school, @visit)) }
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
      format.html { redirect_to(high_school_visits_url(@high_school, :term_id => @term)) }
      format.xml  { head :ok }
    end
  end
  
  protected
  
  def fetch_high_school
    @high_school = HighSchool.find(params[:high_school_id])
  end
  
  def fetch_term
    if params[:new_term_id]
      if params[:new_term_id].is_a?(String)
        abbrev = params[:new_term_id]
      else
        abbrev = "#{params[:new_term_id][:quarter_code_abbreviation]}#{params[:new_term_id][:year]}"
      end
    else
      abbrev = params[:term_id]
    end
    @term = abbrev.blank? ? Term.current_term : Term.find(abbrev)
  end
  
end