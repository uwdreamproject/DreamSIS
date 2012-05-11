class HighSchoolsController < ApplicationController
  # GET /high_schools
  # GET /high_schools.xml
  def index
    @high_schools = HighSchool.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @high_schools }
    end
  end

  # GET /high_schools/1
  # GET /high_schools/1.xml
  def show
    @high_school = HighSchool.find(params[:id])
    @participants = Participant.in_cohort(Participant.current_cohort).in_high_school(@high_school.try(:id))

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @high_school }
    end
  end

  # GET /high_schools/new
  # GET /high_schools/new.xml
  def new
    @high_school = HighSchool.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @high_school }
    end
  end

  # GET /high_schools/1/edit
  def edit
    @high_school = HighSchool.find(params[:id])
  end

  # POST /high_schools
  # POST /high_schools.xml
  def create
    @high_school = HighSchool.new(params[:high_school])

    respond_to do |format|
      if @high_school.save
        flash[:notice] = 'HighSchool was successfully created.'
        format.html { redirect_to(@high_school) }
        format.xml  { render :xml => @high_school, :status => :created, :location => @high_school }
        format.js
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @high_school.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end

  # PUT /high_schools/1
  # PUT /high_schools/1.xml
  def update
    @high_school = HighSchool.find(params[:id])

    respond_to do |format|
      if @high_school.update_attributes(params[:high_school])
        flash[:notice] = 'HighSchool was successfully updated.'
        format.html { redirect_to(@high_school) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @high_school.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /high_schools/1
  # DELETE /high_schools/1.xml
  def destroy
    @high_school = HighSchool.find(params[:id])
    @high_school.destroy

    respond_to do |format|
      format.html { redirect_to(high_schools_url) }
      format.xml  { head :ok }
    end
  end
  
  def survey_codes
    @n = (params[:n] || 100).to_i
    @high_school = HighSchool.find(params[:id])
    @current_cohort = params[:cohort] || Participant.current_cohort
    @participants = Participant.in_cohort(@current_cohort).in_high_school(@high_school.try(:id))
    if params[:mentor_id]
      @mentor = Mentor.find params[:mentor_id]
      @participants = @participants.select{|p| p.mentor_ids.include?(params[:mentor_id].to_i)}
    end
    @unassigned_codes = @high_school.unassigned_survey_ids[0..(@n-1)]
  end
  
  def survey_code_cards
    @n = (params[:n] || 100).to_i
    @high_school = HighSchool.find(params[:id])
    @current_cohort = params[:cohort] || Participant.current_cohort
    @participants = Participant.in_cohort(@current_cohort).in_high_school(@high_school.try(:id))
    if params[:mentor_id]
      @mentor = Mentor.find params[:mentor_id]
      @participants = @participants.select{|p| p.mentor_ids.include?(params[:mentor_id].to_i)}
    end
    @unassigned_codes = @high_school.unassigned_survey_ids[0..(@n-1)]
  end

  def stats
    @high_schools = params[:id].nil? ? HighSchool.partners : [HighSchool.find(params[:id])]
  end
  
end
