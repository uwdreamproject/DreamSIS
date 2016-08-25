class TermsController < ApplicationController
  
  def index
    @terms = Term.all.reverse

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @terms }
    end
  end

  def show
    if params[:id] == "search"
      @term = Term.find(params[:new_term_id])
      return redirect_to @term
    else
      @term = Term.find(params[:id])
    end

     @cache_key = fragment_cache_key(action: :show, id: @term.id, format: :xlsx)

    respond_to do |format|
      format.html { redirect_to edit_term_path(@term) }
      format.xml  { render xml: @term }
      format.xlsx { @mentors = @term.mentors
                    respond_to_xlsx }
    end
  end
  
  def new
    @term = Term.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @term }
    end
  end

  def edit
    @term = Term.find(params[:id])
    @cache_key = fragment_cache_key(action: :show, id: @term.id, format: :xlsx)
    @export = TermMentorsReport.for_key(@cache_key)
    respond_to do |format|
      format.html
    end
  end

  def check_export_status
    @export = TermMentorsReport.find(params[:id])
    respond_to do |format|
      format.html { render text: (@export.try(:status) || "does not exist") }
      format.js
    end
  end

  def create
    @term = Term.new(params[:term])

    respond_to do |format|
      if @term.save
        flash[:notice] = "Term was successfully created."
        format.html { redirect_to(@term) }
        format.xml  { render xml: @term, status: :created, location: @term }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @term.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @term = Term.find(params[:id])

    respond_to do |format|
      if @term.update_attributes(params[:term] || params[:quarter])
        flash[:notice] = 'Term was successfully updated.'
        format.html { redirect_to(terms_path) }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @term.errors, status: :unprocessable_entity }
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
        format.xml  { render xml: @term, status: :unprocessable_entity }
      end
    end
  end
  
  protected 
  
  def check_authorization
    unless @current_user && @current_user.admin?
      render_error("You are not allowed to access that page.")
    end
  end

  def respond_to_xlsx
    @export = TermMentorsReport.find_or_initialize_by_key(@cache_key)
    if @export.generated? && params[:generate].nil?
      if request.xhr?
        headers["Content-Type"] = "text/javascript"
        render js: "window.location = '#{url_for(format: 'xlsx')}'"
      else
        begin
          filename = @filename || "term.xlsx"
          send_data @export.file.read, filename: filename, disposition: 'inline', type: @export.mime_type.to_s
        rescue
          flash[:error] = "The file could not be read from the server. Please try regenerating the export."
          redirect_to :back
        end
      end
    else
      respond_to_generate_xlsx
    end
  end

  def respond_to_generate_xlsx
    @export = TermMentorsReport.find_or_initialize_by_key(@cache_key)
    @export.format = "xlsx"
    @export.object_ids = @mentors.collect(&:id)
    @export.reset_to_ungenerated
    @export.status = "initializing"
    @export.save
    @export.generate_in_background!
    flash[:notice] = "We are generating your Excel file for you. Please wait."

    if request.xhr?
      headers["Content-Type"] = "text/javascript"
      return render(template: "terms/check_export_status.js.erb", format: 'js')
    else
      return redirect_to(term_path(@term))
    end
  end

end
