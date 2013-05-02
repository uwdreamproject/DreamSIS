class TermsController < ApplicationController
  
  def index
    @terms = Term.all.reverse

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @terms }
    end
  end

  def show
    if params[:id] == "search"
      @term = Term.find(params[:new_term_id])
      return redirect_to @term
    else
      @term = Term.find(params[:id])
    end

    respond_to do |format|
      format.html { redirect_to edit_term_path(@term) }
      format.xml  { render :xml => @term }
    end
  end

  def edit
    @term = Term.find(params[:id])
  end

  def update
    @term = Term.find(params[:id])

    respond_to do |format|
      if @term.update_attributes(params[:term])
        flash[:notice] = 'Term was successfully updated.'
        format.html { redirect_to(terms_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @term.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @term = Term.find(params[:id])
    @term.destroy

    respond_to do |format|
      format.html { redirect_to(terms_url) }
      format.xml  { head :ok }
    end
  end
  
  def sync
    @term = Term.find(params[:id])
    
    respond_to do |format|
      if @term.sync_with_resource!
        flash[:notice] = "Successfully synced with UW academic calendar."
        format.html { redirect_to @term }
        format.xml  { head :ok }
      else
        flash[:error] = "Couldn't sync term information."
        format.html { redirect_to @term }
        format.xml  { render :xml => @term, :status => :unprocessable_entity }
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