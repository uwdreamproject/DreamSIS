class TrainingsController < ApplicationController
  skip_before_filter :check_authorization, only: [:take]
  
  def index
    @trainings = Training.find :all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @trainings }
    end
  end

  def show
    @training = Training.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @training }
    end
  end
  
  def take
    @training = Training.find(params[:id])
    @include_mediaelement = true
    apply_extra_stylesheet(@training.stylesheet_url) unless @training.stylesheet_url.blank?
  end
  
  def complete
    @training = Training.find(params[:id])
    @training_completion = @current_user.person.training_completions.find_or_initialize_by_training_id(@training.id)
    @training_completion.completed_at = Time.now
    
    respond_to do |format|
      if @training_completion.save
        flash[:notice] = "Thanks for completing the training!"
        format.js { head :ok }
      end
    end
      
  end

  def new
    @training = Training.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @training }
    end
  end

  def edit
    @training = Training.find(params[:id])
  end

  def create
    @training = Training.new(params[:training])

    respond_to do |format|
      if @training.save
        flash[:notice] = "Training was successfully created."
        format.html { redirect_to(@training) }
        format.xml  { render xml: @training, status: :created, location: @training }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @training.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @training = Training.find(params[:id])

    respond_to do |format|
      if @training.update_attributes(params[:training])
        flash[:notice] = "Training was successfully updated."
        format.html { redirect_to(@training) }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @training.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @training = Training.find(params[:id])
    @training.destroy

    respond_to do |format|
      format.html { redirect_to(trainings_url) }
      format.xml  { head :ok }
    end
  end
end