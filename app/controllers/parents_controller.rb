class ParentsController < ParticipantsController
  before_filter :fetch_participant
  skip_before_filter :check_authorization
  
  # GET /participant/parents
  # GET /participant/parents.xml
  def index
    @parents = @participant.parents.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @parents }
    end
  end

  # GET /participant/parents/1
  # GET /participant/parents/1.xml
  def show
    @parent = @participant.parents.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @parent }
    end
  end

  # GET /participant/parents/new
  # GET /participant/parents/new.xml
  def new
    @parent = @participant.parents.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @parent }
    end
  end

  # GET /participant/parents/1/edit
  def edit
    @parent = @participant.parents.find(params[:id])
  end

  # POST /participant/parents
  # POST /participant/parents.xml
  def create
    @parent = @participant.parents.new(params[:parent])

    respond_to do |format|
      if @parent.save
        flash[:notice] = 'Parent was successfully created.'
        format.html { redirect_to(participant_path(@participant, anchor: "!/section/parents")) }
        format.xml  { render xml: @parent, status: :created, location: @participant }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @parent.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /participant/parents/1
  # PUT /participant/parents/1.xml
  def update
    @parent = @participant.parents.find(params[:id])

    respond_to do |format|
      if @parent.update_attributes(params[:parent])
        flash[:notice] = 'Parent was successfully updated.'
        format.html { redirect_to(participant_path(@participant, anchor: "!/section/parents")) }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @parent.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /participant/parents/1
  # DELETE /participant/parents/1.xml
  def destroy
    @parent = @participant.parents.find(params[:id])
    @parent.destroy

    respond_to do |format|
      format.html { redirect_to(participant_path(@participant, anchor: "!/section/parents")) }
      format.xml  { head :ok }
    end
  end

  protected
  
  def fetch_participant
    @participant = Participant.find(params[:participant_id])

    unless @current_user && @current_user.can_view?(@participant)
      flash[:error] = "You are not allowed to edit this participant"
      return redirect_to :back
    end
  end
  
end
