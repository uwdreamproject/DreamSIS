class NotesController < ApplicationController
  skip_before_filter :check_authorization
  before_filter :verify_permissions, only: [:edit, :update, :destroy]
  
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
        format.html { redirect_to polymorphic_path(@note.notable, anchor: "!/section/notes/#{@note.id}") }
        format.js
      else
        format.html { render action: "edit" }
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
    
  protected
  
  def verify_permissions
    @note = Note.find params[:id]
    if @note.user != @current_user && @current_user.can_edit?(@note.notable) && params[:note].try(:[], :needs_followup)
      # The user is trying to change the followup flag, and has permission. Allow *only* this change.
      params[:note] = { needs_followup: params[:note].try(:[], :needs_followup) }
    else
      # The user does not own the note and cannot edit it.
      render_error("You can only edit or delete your own notes.") unless @note.user == @current_user
    end
  end
  
end
