class MentorTermGroupsController < ApplicationController
  before_filter :fetch_term

  def term
    return redirect_to action: "index" if @term.nil?
    return redirect_to mentor_term_groups_term_path(@term) if params[:new_term_id]
    @mentor_term_groups = @term.mentor_term_groups
    @max_term_cap = @mentor_term_groups.collect(&:capacity).numeric_items.max
    @max_term_size = @mentor_term_groups.collect(&:mentor_terms_count).numeric_items.max
    render action: (params[:show] == 'schedule' ? "schedule" : "index")
  end
  
  def index
    @mentor_term_groups = @term.mentor_term_groups
    @max_term_cap = @mentor_term_groups.collect(&:capacity).numeric_items.max
    @max_term_size = @mentor_term_groups.collect(&:mentor_terms_count).numeric_items.max

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @mentor_term_groups }
    end
  end

  def show
    @mentor_term_group = MentorTermGroup.find(params[:id])
    @mentor_terms = @mentor_term_group.mentor_terms

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @mentor_term_group }
    end
  end

  def photo_tile
    @mentor_term_group = MentorTermGroup.find(params[:id])
    @mentor_terms = @mentor_term_group.mentor_terms
    
    respond_to do |format|
      format.html
    end
  end

  def new
    @mentor_term_group = MentorTermGroup.new(term_id: @term.try(:id))

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @mentor_term_group }
    end
  end

  def edit
    @mentor_term_group = MentorTermGroup.find(params[:id])
  end

  def create
    @mentor_term_group = MentorTermGroup.new(params[:mentor_term_group])

    respond_to do |format|
      if @mentor_term_group.save
        flash[:notice] = 'MentorTermGroup was successfully created.'
        format.html { redirect_to(@mentor_term_group) }
        format.xml  { render xml: @mentor_term_group, status: :created, location: @mentor_term_group }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @mentor_term_group.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @mentor_term_group = MentorTermGroup.find(params[:id])
    
    respond_to do |format|
      if @mentor_term_group.update_attributes(params[:mentor_term_group])
        flash[:notice] = 'MentorTermGroup was successfully updated.'
        format.html { redirect_to(@mentor_term_group) }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @mentor_term_group.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @mentor_term_group = MentorTermGroup.find(params[:id])
    @mentor_term_group.destroy

    respond_to do |format|
      format.html { redirect_to(mentor_term_groups_url) }
      format.xml  { head :ok }
    end
  end
  
  def sync
    if params[:id]
      @mentor_term_group = MentorTermGroup.find(params[:id])
      original_size = @mentor_term_group.mentor_terms_count
      @mentor_term_group.sync_with_course!
      new_size = @mentor_term_group.reload.mentor_terms_count
      flash[:notice] = "Successfully synced course enrollees. Went from #{view_context.pluralize(original_size, "mentor")} to #{view_context.pluralize(new_size, "mentor")}."
    else
      @mentor_term_group = nil
      @term.mentor_term_groups.collect(&:sync_with_course!)
      flash[:notice] = "Successfully synced course enrollees for #{@term.title}."
    end

    respond_to do |format|
      format.html { redirect_to(@mentor_term_group || mentor_term_groups_term_path(@term.to_param)) }
      format.xml  { head :ok }
    end
  end
  
  def create_from_linked_sections
    respond_to do |format|
      if MentorTermGroup.create_from_linked_sections!(@term)
        flash[:notice] = "Successfully created mentor groups for #{@term.title}."
        format.html { redirect_to(mentor_term_groups_term_path(@term.to_param)) }
        format.xml  { head :ok }
      else
        flash[:error] = "Sorry, but something went wrong."
        format.html { redirect_to(mentor_term_groups_term_path(@term.to_param)) }
        format.xml  { render xml: @mentor_term_group.errors, status: :unprocessable_entity }
      end
    end
  end
    
  protected
  
  def fetch_term
    @term = (Term.find(params[:new_term_id] || params[:term_id] || params[:term]) rescue nil) || Term.current_term || Term.allowing_signups.try(:first) || Term.last
    unless @term
      return render_error("You must define a term first before you can modify mentor groups.", "Unable to display page.")
    end
  end
  
end
