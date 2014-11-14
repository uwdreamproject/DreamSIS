class NotesController < ApplicationController
  skip_before_filter :check_authorization
  before_filter :verify_permissions, :only => [:edit, :update, :destroy]
  
  def edit
    @note = Note.find params[:id]
  end

	def create
		@note = Note.new(params[:note])
	
    respond_to do |format|
      if @note.save
        flash[:notice] = 'Note was successfully created.'
        format.html { redirect_back_or_default(edit_note_path(@note)) }
				format.js
      else
				flash[:error] = "Could not save note. #{@note.errors.full_messages.to_sentence}"
        format.html { redirect_to :back }
        format.js
      end
    end
		
	end

  def update
    @note = Note.find(params[:id])

    respond_to do |format|
      if @note.update_attributes(params[:note] || params[:document])
        flash[:notice] = "Successfully updated note."
        format.html { redirect_to @note.notable }
        format.js
      else
        format.html { render :action => "edit" }
        format.js
      end
    end
  end

  def destroy
    @note = Note.find(params[:id])
    @note.destroy

    respond_to do |format|
      format.html { redirect_to redirect_to_path }
      format.js
    end
  end
    
  # def document
  #     @note = Note.find(params[:id])
  #
  #     if @note.notable.is_a?(Person)
  #       @person = @note.notable
  #       unless @current_user && @current_user.can_view?(@person)
  #         return render_error("You are not allowed to view documents for that person.")
  #       end
  #     end
  #
  #     send_data @note.document.read, :type => @note.document_content_type, :filename => @note.document_file_name
  # end

  protected
  
  def verify_permissions
    @note = Note.find params[:id]
    unless @note.user == @current_user
      render_error("You can only edit or delete your own notes.")
    end
  end
  
end
