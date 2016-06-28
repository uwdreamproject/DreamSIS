class TestScoresController < ParticipantsController
  before_filter :fetch_participant
  skip_before_filter :check_authorization
  
  # GET /participant/test_scores
  # GET /participant/test_scores.xml
  def index
    @test_scores = @participant.test_scores.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @test_scores }
    end
  end

  # GET /participant/test_scores/1
  # GET /participant/test_scores/1.xml
  def show
    @test_score = @participant.test_scores.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @test_score }
    end
  end

  # GET /participant/test_scores/new
  # GET /participant/test_scores/new.xml
  def new
    @test_score = @participant.test_scores.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @test_score }
    end
  end

  # GET /participant/test_scores/1/edit
  def edit
    @test_score = @participant.test_scores.find(params[:id])
  end

  # POST /participant/test_scores
  # POST /participant/test_scores.xml
  def create
    @test_score = @participant.test_scores.new(test_type_id: params[:test_score][:test_type_id])
    @test_score.test_type.reload
    @test_score.add_section_score_attribute_methods
    @test_score.attributes = params[:test_score]


    respond_to do |format|
      if @test_score.save
        flash[:notice] = 'TestScore was successfully created.'
        format.html { redirect_to participant_path(@participant, anchor: "!/section/test_scores") }
        format.xml  { render xml: @test_score, status: :created, location: @participant }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @test_score.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /participant/test_scores/1
  # PUT /participant/test_scores/1.xml
  def update
    @test_score = @participant.test_scores.find(params[:id])
    @test_score.test_type_id = params[:test_score][:test_type_id]
    @test_score.test_type.reload
    @test_score.add_section_score_attribute_methods

    respond_to do |format|
      if @test_score.update_attributes(params[:test_score])
        flash[:notice] = 'TestScore was successfully updated.'
        format.html { redirect_to participant_path(@participant, anchor: "!/section/test_scores") }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @test_score.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /participant/test_scores/1
  # DELETE /participant/test_scores/1.xml
  def destroy
    @test_score = @participant.test_scores.find(params[:id])
    @test_score.destroy

    respond_to do |format|
      format.html { redirect_to participant_path(@participant, anchor: "!/section/test_scores") }
      format.xml  { head :ok }
    end
  end

  def update_scores_fields
    @test_score = params[:id] ? @participant.test_scores.find(params[:id]) : @participant.test_scores.new(params[:test_score])
    @test_score.test_type_id = params[:test_score][:test_type_id]
    @test_score.test_type.reload
    @test_score.add_section_score_attribute_methods
    
    respond_to do |format|
      format.js
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
