class FinancialAidPackagesController < ParticipantsController
  before_filter :fetch_participant
  skip_before_filter :check_authorization

  
  # GET /financial_aid_packages
  # GET /financial_aid_packages.json
  def index
    @financial_aid_packages = @participant.financial_aid_packages

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @financial_aid_packages }
    end
  end

  # GET /financial_aid_packages/1
  # GET /financial_aid_packages/1.json
  def show
    @financial_aid_package = @participant.financial_aid_packages.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @financial_aid_package.to_json(methods: [:breakdown]) }
    end
  end

  # GET /financial_aid_packages/new
  # GET /financial_aid_packages/new.json
  def new
    @financial_aid_package = @participant.financial_aid_packages.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @financial_aid_package }
    end
  end

  # GET /financial_aid_packages/1/edit
  def edit
    @financial_aid_package = @participant.financial_aid_packages.find(params[:id])
  end

  # POST /financial_aid_packages
  # POST /financial_aid_packages.json
  def create
    @financial_aid_package = @participant.financial_aid_packages.new(params[:financial_aid_package])

    respond_to do |format|
      if @financial_aid_package.save
        format.html { redirect_to [@participant, @financial_aid_package], notice: 'Financial aid package was successfully created.' }
        format.json { render json: @financial_aid_package, status: :created, location: [@participant, @financial_aid_package] }
      else
        format.html { render action: "new" }
        format.json { render json: @financial_aid_package.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /financial_aid_packages/1
  # PUT /financial_aid_packages/1.json
  def update
    @financial_aid_package = @participant.financial_aid_packages.find(params[:id])

    respond_to do |format|
      if @financial_aid_package.update_attributes(params[:financial_aid_package])
        format.html { redirect_to [@participant, @financial_aid_package], notice: 'Financial aid package was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @financial_aid_package.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /financial_aid_packages/1
  # DELETE /financial_aid_packages/1.json
  def destroy
    @financial_aid_package = @participant.financial_aid_packages.find(params[:id])
    @financial_aid_package.destroy

    respond_to do |format|
      format.html { redirect_to [@participant, @financial_aid_package] }
      format.json { head :no_content }
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
