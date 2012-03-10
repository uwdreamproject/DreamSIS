class QuartersController < ApplicationController
  
  def index
    @quarters = Quarter.all.reverse

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @quarters }
    end
  end

  def show
    if params[:id] == "search"
      @quarter = Quarter.find(params[:new_quarter_id])
      return redirect_to @quarter
    else
      @quarter = Quarter.find(params[:id])
    end

    respond_to do |format|
      format.html { redirect_to edit_quarter_path(@quarter) }
      format.xml  { render :xml => @quarter }
    end
  end

  def edit
    @quarter = Quarter.find(params[:id])
  end

  def update
    @quarter = Quarter.find(params[:id])

    respond_to do |format|
      if @quarter.update_attributes(params[:quarter])
        flash[:notice] = 'Quarter was successfully updated.'
        format.html { redirect_to(quarters_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @quarter.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @quarter = Quarter.find(params[:id])
    @quarter.destroy

    respond_to do |format|
      format.html { redirect_to(quarters_url) }
      format.xml  { head :ok }
    end
  end
  
  def sync
    @quarter = Quarter.find(params[:id])
    
    respond_to do |format|
      if @quarter.sync_with_resource!
        flash[:notice] = "Successfully synced with UW academic calendar."
        format.html { redirect_to @quarter }
        format.xml  { head :ok }
      else
        flash[:error] = "Couldn't sync term information."
        format.html { redirect_to @quarter }
        format.xml  { render :xml => @quarter, :status => :unprocessable_entity }
      end
    end
  end
  
  protected 
  
  def check_authorization
    unless @current_user && @current_user.admin?
      render_error("You are not allowed to access that page.")
    end
  end
  
  
end