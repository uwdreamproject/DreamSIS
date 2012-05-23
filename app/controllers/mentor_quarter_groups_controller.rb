class MentorQuarterGroupsController < ApplicationController
  before_filter :fetch_quarter

  def quarter
    return redirect_to :action => "index" if @quarter.nil?
    return redirect_to mentor_quarter_groups_quarter_path(@quarter) if params[:new_quarter_id]
    @mentor_quarter_groups = @quarter.mentor_quarter_groups
    @max_quarter_cap = @mentor_quarter_groups.collect(&:capacity).numeric_items.max
    @max_quarter_size = @mentor_quarter_groups.collect(&:mentor_quarters_count).numeric_items.max
    render :action => (params[:show] == 'schedule' ? "schedule" : "index")
  end
  
  def index
    @mentor_quarter_groups = @quarter.mentor_quarter_groups
    @max_quarter_cap = @mentor_quarter_groups.collect(&:capacity).numeric_items.max
    @max_quarter_size = @mentor_quarter_groups.collect(&:mentor_quarters_count).numeric_items.max

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mentor_quarter_groups }
    end
  end

  def show
    @mentor_quarter_group = MentorQuarterGroup.find(params[:id])
    @mentor_quarters = @mentor_quarter_group.mentor_quarters

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mentor_quarter_group }
    end
  end

  def photo_tile
    @mentor_quarter_group = MentorQuarterGroup.find(params[:id])
    @mentor_quarters = @mentor_quarter_group.mentor_quarters
    
    respond_to do |format|
      format.html
    end
  end

  def new
    @mentor_quarter_group = MentorQuarterGroup.new(:quarter_id => @quarter.try(:id))

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mentor_quarter_group }
    end
  end

  def edit
    @mentor_quarter_group = MentorQuarterGroup.find(params[:id])
  end

  def create
    @mentor_quarter_group = MentorQuarterGroup.new(params[:mentor_quarter_group])

    respond_to do |format|
      if @mentor_quarter_group.save
        flash[:notice] = 'MentorQuarterGroup was successfully created.'
        format.html { redirect_to(@mentor_quarter_group) }
        format.xml  { render :xml => @mentor_quarter_group, :status => :created, :location => @mentor_quarter_group }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mentor_quarter_group.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @mentor_quarter_group = MentorQuarterGroup.find(params[:id])
    
    respond_to do |format|
      if @mentor_quarter_group.update_attributes(params[:mentor_quarter_group])
        flash[:notice] = 'MentorQuarterGroup was successfully updated.'
        format.html { redirect_to(@mentor_quarter_group) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mentor_quarter_group.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @mentor_quarter_group = MentorQuarterGroup.find(params[:id])
    @mentor_quarter_group.destroy

    respond_to do |format|
      format.html { redirect_to(mentor_quarter_groups_url) }
      format.xml  { head :ok }
    end
  end
  
  def sync
    if params[:id]
      @mentor_quarter_group = MentorQuarterGroup.find(params[:id])
      original_size = @mentor_quarter_group.mentor_quarters_count
      @mentor_quarter_group.sync_with_course!
      new_size = @mentor_quarter_group.mentor_quarters_count
      flash[:notice] = "Successfully synced course enrollees. Went from #{@template.pluralize(original_size, "mentor")} to #{@template.pluralize(new_size, "mentor")}."
    else
      @mentor_quarter_group = nil
      @quarter.mentor_quarter_groups.collect(&:sync_with_course!)
      flash[:notice] = "Successfully synced course enrollees for #{@quarter.title}."
    end

    respond_to do |format|
      format.html { redirect_to(@mentor_quarter_group || mentor_quarter_groups_quarter_path(@quarter.to_param)) }
      format.xml  { head :ok }
    end    
  end
  
  def create_from_linked_sections
    respond_to do |format|
      if MentorQuarterGroup.create_from_linked_sections!(@quarter)
        flash[:notice] = "Successfully created mentor groups for #{@quarter.title}."
        format.html { redirect_to(mentor_quarter_groups_quarter_path(@quarter.to_param)) }
        format.xml  { head :ok }
      else
        flash[:error] = "Sorry, but something went wrong."
        format.html { redirect_to(mentor_quarter_groups_quarter_path(@quarter.to_param)) }
        format.xml  { render :xml => @mentor_quarter_group.errors, :status => :unprocessable_entity }
      end
    end    
  end
    
  protected
  
  def fetch_quarter
    @quarter = (Quarter.find(params[:new_quarter_id] || params[:quarter_id]) rescue nil) || Quarter.current_quarter || Quarter.allowing_signups.try(:first) || Quarter.last
  end
  
end