class ParticipantGroupsController < ApplicationController
  skip_before_filter :check_authorization, :only => [:show]
  
  def index
    @participant_groups = ParticipantGroup.find :all, :include => [ :location ]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @participant_groups }
    end
  end

  def high_school
    @high_school = HighSchool.find(params[:high_school_id])
    @participant_groups = ParticipantGroup.find :all, :include => [ :location ], :conditions => { :location_id => @high_school }
    
    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml  { render :xml => @participant_groups }
    end
  end

  def show
    redirect_to participant_group_participants_path(params[:id])
  end

  def new
    @participant_group = ParticipantGroup.new(params[:participant_group])

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @participant_group }
    end
  end

  def edit
    @participant_group = ParticipantGroup.find(params[:id])
  end

  def create
    @participant_group = ParticipantGroup.new(params[:participant_group])

    respond_to do |format|
      if @participant_group.save
        flash[:notice] = "ParticipantGroup was successfully created."
        format.html { redirect_to(@participant_group) }
        format.xml  { render :xml => @participant_group, :status => :created, :location => @participant_group }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @participant_group.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @participant_group = ParticipantGroup.find(params[:id])

    respond_to do |format|
      if @participant_group.update_attributes(params[:participant_group])
        flash[:notice] = "ParticipantGroup was successfully updated."
        format.html { redirect_to(@participant_group) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @participant_group.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @participant_group = ParticipantGroup.find(params[:id])
    @participant_group.destroy

    respond_to do |format|
      format.html { redirect_to(participant_groups_url) }
      format.xml  { head :ok }
    end
  end
end
