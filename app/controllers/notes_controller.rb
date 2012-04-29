class NotesController < ApplicationController
  
  before_filter :verify_permissions, :only => [:edit, :update, :destroy]
  
  def edit
    @note = Note.find params[:id]
  end

  def update
    @note = Note.find(params[:id])

    respond_to do |format|
      if @note.update_attributes(params[:note])
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
    
  protected
  
  def verify_permissions
    @note = Note.find params[:id]
    unless @note.user == @current_user
      render_error("You can only edit or delete your own notes.")
    end
  end
  
end
